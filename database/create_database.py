"""Build database/lannkz_analytics.db from data/processed/lannkz_videos_cleaned.csv.

Run from the repository root: python database/create_database.py
Requires Python 3; no third-party packages.
"""
import csv
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = ROOT / 'data' / 'processed' / 'lannkz_videos_cleaned.csv'
DB_PATH = ROOT / 'database' / 'lannkz_analytics.db'

COLUMN_TYPES = {
    'video_id': 'TEXT',
    'video_title': 'TEXT',
    'publish_date': 'TEXT',
    'video_duration_seconds': 'INTEGER',
    'engaged_views': 'INTEGER',
    'avg_view_duration': 'REAL',
    'avg_percentage_viewed': 'REAL',
    'views': 'INTEGER',
    'watch_time_hours': 'REAL',
    'subscribers_gained': 'INTEGER',
    'impressions': 'INTEGER',
    'ctr': 'REAL',
    'avd_seconds': 'INTEGER',
    'content_type': 'TEXT',
    'football_relevance': 'TEXT',
    'release_relevance': 'TEXT',
    'avd_duration_ratio': 'REAL',
    'retention_difference': 'REAL',
}


def main():
    if not CSV_PATH.is_file():
        raise SystemExit(f'Missing CSV: {CSV_PATH}')
    with CSV_PATH.open(newline='', encoding='utf-8-sig') as file:
        reader = csv.DictReader(file)
        if reader.fieldnames != list(COLUMN_TYPES):
            raise SystemExit('CSV headers do not match expected 18 columns. Check column names and order.')
        records = list(reader)

    if len(records) != 58:
        raise SystemExit(f'Expected 58 video records; found {len(records)}.')
    ids = [row['video_id'].strip() for row in records]
    if len(set(ids)) != len(ids) or any(not value for value in ids):
        raise SystemExit('Video IDs must be unique and nonempty.')

    values = []
    for line_no, row in enumerate(records, 2):
        try:
            values.append(tuple(
                int(row[col]) if typ == 'INTEGER' else
                float(row[col]) if typ == 'REAL' else
                row[col]
                for col, typ in COLUMN_TYPES.items()
            ))
        except (ValueError, TypeError) as error:
            raise SystemExit(f'Invalid data on CSV line {line_no}: {error}') from error

    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    schema = ',\n    '.join(
        f'"{col}" {typ}' + (' PRIMARY KEY' if col == 'video_id' else ' NOT NULL')
        for col, typ in COLUMN_TYPES.items()
    )
    with sqlite3.connect(DB_PATH) as conn:
        with conn:
            conn.execute('DROP TABLE IF EXISTS videos')
            conn.execute(f'CREATE TABLE videos (\n    {schema}\n)')
            cols = ', '.join(f'"{col}"' for col in COLUMN_TYPES)
            placeholders = ', '.join('?' for _ in COLUMN_TYPES)
            conn.executemany(f'INSERT INTO videos ({cols}) VALUES ({placeholders})', values)
        count = conn.execute('SELECT COUNT(*) FROM videos').fetchone()[0]
    print(f'Created {DB_PATH} with {count} videos and {len(COLUMN_TYPES)} columns.')


if __name__ == '__main__':
    main()
