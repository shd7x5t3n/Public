#!/usr/bin/python3
import praw
import time
import openai
import nltk
import re
import os
from nltk.tokenize import sent_tokenize
from datetime import datetime
import pytz
import logging
import random
import logging.handlers
import json

# Set up logging
log_file = '/scripts/reddit_error.log'

# Set up logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Set up rotating log handler to limit file size and remove oldest log entries
max_log_size = 100 * 1024 * 1024  # 100MB
log_handler = logging.handlers.RotatingFileHandler(log_file, maxBytes=max_log_size, backupCount=5)
log_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logger.addHandler(log_handler)

# Load configuration from config.json
with open('config.json', 'r') as config_file:
    config = json.load(config_file)

# Extract Reddit and OpenAI credentials from the loaded config
reddit_credentials = config["reddit"]
openai_api_key = config["openai"]["api_key"]

# Initialize the Reddit API wrapper
reddit = praw.Reddit(
    client_id=reddit_credentials["client_id"],
    client_secret=reddit_credentials["client_secret"],
    user_agent=reddit_credentials["user_agent"],
    username=reddit_credentials["username"],
    password=reddit_credentials["password"]
)

# Initialize OpenAI API
openai.api_key = openai_api_key

# Define the rate limiting function for Reddit
def reddit_rate_limit(min_seconds, max_seconds):
    time.sleep(random.uniform(min_seconds, max_seconds))

# Define the rate limiting function for OpenAI GPT-3 API
def gpt3_rate_limit():
    time.sleep(20)  # Adjust this based on OpenAI's rate limits for free tier

# Define the is_valid_response function
def is_valid_response(text):
    words = nltk.word_tokenize(text)
    if len(words) < 3:
        return False

    if not any(char.isalpha() for char in text):
        return False

    if not text[0].isupper():
        return False

    if text[-1] not in ".!?":
        return False

    return True

# Define the compose_response function
def compose_response(post_title, post_content, comments):
    prompt = f"Post Title: {post_title}\nPost Content: {post_content}\nComments: {' '.join([comment.body for comment in comments])}"
    response = openai.Completion.create(
        engine="text-davinci-002",
        prompt=prompt,
        max_tokens=100,
        stop=["\n", "Post Title:"],
        temperature=0.7,
        n=1
    )

    if response and response["choices"]:
        generated_text = response["choices"][0]["text"]
        sentences = sent_tokenize(generated_text)
        filtered_sentences = [sentence for sentence in sentences if is_valid_response(sentence)]
        generated_text = ' '.join(filtered_sentences)
        words = nltk.word_tokenize(generated_text)
        if len(words) < 3:
            return None
        generated_text = generated_text.strip()
        if generated_text[-1] not in ".!?":
            generated_text += "."
        return generated_text

    return None

# Define the reddit_post_comment function
def reddit_post_comment(submission, comment_text):
    submission.reply(comment_text)
    logger.info("Posted comment in subreddit '%s': '%s'", submission.subreddit.display_name, comment_text)
    logger.info("Original post by u/%s: '%s'", submission.author, submission.title)

# Define the run_bot function
def run_bot():
    logger.info("Bot started.")

    subreddit_names = [
        "technology",
        "worldnews",
        "AskReddit",
        "movies",
        "sports",
        "todayilearned",
    ]

    while True:
        try:
            now = datetime.now(pytz.timezone("US/Central"))
            current_hour = now.hour

            if 7 <= current_hour < 21:
                subreddit_name = random.choice(subreddit_names)
                subreddit = reddit.subreddit(subreddit_name)

                for submission in subreddit.new(limit=5):
                    submission.comments.replace_more(limit=None)
                    comment_posted = False  # Flag to track if comment has been posted

                    for comment in submission.comments:
                        if not comment_posted:
                            response = compose_response(submission.title, submission.selftext, submission.comments)
                            if response:
                                reddit_post_comment(comment, response)
                                gpt3_rate_limit()
                                comment_posted = True  # Set the flag after posting a comment
                                sleep_duration = random.randint(300, 1800)
                                logger.info("Sleeping between comments for %d seconds.", sleep_duration)
                                time.sleep(sleep_duration)

            else:
                logger.info("Not posting comments between 9pm and 7am.")

            subreddit_check_sleep = 600
            logger.info("Sleeping between subreddit checks for %d seconds.", subreddit_check_sleep)
            time.sleep(subreddit_check_sleep)

        except openai.error.RateLimitError as rle:
            error_message = str(rle)
            wait_time = re.search(r'Please try again in (\d+)([a-z]+)', error_message)
            if wait_time:
                wait_time_value = int(wait_time.group(1))
                wait_time_unit = wait_time.group(2)
                if wait_time_unit.startswith('s'):
                    wait_time_seconds = wait_time_value
                elif wait_time_unit.startswith('m'):
                    wait_time_seconds = wait_time_value * 60
                else:
                    wait_time_seconds = 0
                logger.warning("Rate limit error: %s", error_message)
                logger.info("Sleeping for %d seconds due to rate limit error.", wait_time_seconds)
                time.sleep(wait_time_seconds)
            else:
                logger.error("Rate limit error occurred: %s", error_message)
        except Exception as e:
            logger.error("Error occurred: %s", str(e))

if __name__ == "__main__":
    run_bot()
