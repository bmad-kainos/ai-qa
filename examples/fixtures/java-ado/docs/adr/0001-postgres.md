# ADR 0001: PostgreSQL

Orders are persisted in PostgreSQL; integration tests require a disposable database. Keep isolated fixture records and reset them between runs.
