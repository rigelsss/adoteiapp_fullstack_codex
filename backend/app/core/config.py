from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    secret_key: str = "adotei-secret-key-local-dev-2024"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    database_url: str = "sqlite:///./adotei.db"

    model_config = {"env_file": ".env"}


settings = Settings()
