# Reddit Bot with OpenAI GPT-3 Integration

This Python script is designed to automate a Reddit bot that generates and posts comments on specified subreddits using the OpenAI GPT-3 API. The bot selects new posts from various subreddits, generates relevant comments based on the post content and title, and posts the comments on the respective submissions.

## Prerequisites

Before running the script, ensure you have the following:

- Python 3.x installed on your system.
- Reddit API credentials (client ID, client secret, user agent, username, and password).
- OpenAI GPT-3 API key.
- Configuration JSON file named `config.json` containing Reddit and OpenAI API credentials.

## Dependencies

The script relies on the following Python libraries:

- `praw`: The Python Reddit API Wrapper, for accessing Reddit's API.
- `openai`: OpenAI Python library for interacting with the GPT-3 API.
- `nltk`: The Natural Language Toolkit, for text processing and tokenization.
- `pytz`: Python timezone library, for handling timezones.
- `logging`: Python's built-in logging library, for error and info logging.

Make sure to install these dependencies using the following command:

```bash
pip install praw openai nltk pytz
```

## How to Use

1. Clone the repository or copy the script to your local machine.

2. Create a `config.json` file in the same directory as the script. Populate it with your Reddit and OpenAI API credentials in the following format:

```json
{
  "reddit": {
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "user_agent": "YOUR_USER_AGENT",
    "username": "YOUR_USERNAME",
    "password": "YOUR_PASSWORD"
  },
  "openai": {
    "api_key": "YOUR_OPENAI_API_KEY"
  }
}
```

3. Adjust the configuration in the script as needed, such as subreddit names, rate limiting, and response filtering.

4. Run the script using the following command:

```bash
python script_name.py
```

The script will start the bot, which will continuously monitor selected subreddits, generate comments using GPT-3, and post comments on eligible submissions.

## Important Notes

- Be mindful of Reddit's terms of use and follow their guidelines when using this script.
- Be aware of OpenAI's rate limits and adjust the rate limiting functions accordingly.
- Keep your API keys and sensitive information secure.
- Regularly review the script and its behavior to ensure it's working as intended.

- ## License

This project is licensed under the terms of the GNU General Public License v3.0. For more details, please see the [LICENSE](LICENSE) file.

## Disclaimer

This script is provided as-is and may require modifications to fit your specific use case. Use it responsibly and adhere to Reddit's and OpenAI's terms of service. The creators of this script are not responsible for any misuse or unintended consequences of its usage.
