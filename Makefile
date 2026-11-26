.PHONY: dev build lint format test cov docs docs-serve example clean kill

LINT_PATHS := fastadmin tests examples

# Create the local environment: Python deps via uv (all ORM/framework extras
# plus the dev group) and the frontend via yarn.
dev:
	uv sync --all-extras
	make -C frontend install

# Build the frontend into fastadmin/static and package the wheel + sdist.
build:
	make -C frontend build
	uv build

# Blocking gate: ruff check + format + ty, then the frontend linters.
lint:
	uv run ruff check $(LINT_PATHS)
	uv run ruff format --check $(LINT_PATHS)
	uv run ty check fastadmin
	make -C frontend lint

format:
	uv run ruff check --fix $(LINT_PATHS)
	uv run ruff format $(LINT_PATHS)
	make -C frontend fix

# -n auto runs the suite in parallel via pytest-xdist. Each worker gets its own
# SQLite file (Django/Pony) with a busy timeout, so there are no "database is
# locked" failures.
test:
	uv run pytest -n auto --cov=fastadmin --cov-report=term-missing --cov-report=xml tests
	make -C frontend test

cov: test

