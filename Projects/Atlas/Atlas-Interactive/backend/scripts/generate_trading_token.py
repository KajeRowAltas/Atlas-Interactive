from __future__ import annotations

import secrets


def main() -> int:
    print(secrets.token_urlsafe(32))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

