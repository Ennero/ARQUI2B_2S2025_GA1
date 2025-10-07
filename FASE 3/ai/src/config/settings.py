# MIT License

# Bondel Technologies S. A.

# Copyright (c) 2025, all rights reserved.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# For more information, contact https://github.com/marcosbondel

# · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
# · 

from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import HttpUrl, Field
import os


class Settings(BaseSettings):

    app_name: str = Field(min_length=5)
    stage: str = Field(frozen=True)
    api_url: HttpUrl
    perform_algorithm_for: str # weapons|plates|faces
    
    # Database settings
    mongo_uri: str = os.getenv('MONGO_URI')
    mongo_username: str = Field(min_length=5, frozen=True)
    mongo_password: str = Field(min_length=12, frozen=True)
    mongo_database: str = Field(min_length=12, frozen=True)

    # Third-party devics
    video_source: str = Field(default='0', frozen=True) # "0", "1" or URL
    conf_weapon: float = Field(default=0.45)

    ocr_langs: str = 'en'
    read_every_n_frames: int = 5
    conf_ocr_min: float = 0.3
    plate_regex_pattern: str = r"[A-Z0-9]{5,8}"
    plate_min_chars: int = 5

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        arbitrary_types_allowed=True,
        env_prefix="",
        extra="ignore"
    )

settings = Settings()