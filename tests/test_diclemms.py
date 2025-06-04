import os
import struct
import datetime

# Minimal DBF utilities for test
RECORD_LEN = 1 + 30 + 30  # deletion flag + word + lemma
HEADER_LEN = 32 + 32 * 2 + 1


def create_dbf(path):
    """Create empty DBF with WORD and LEMMA fields."""
    now = datetime.date.today()
    header = struct.pack(
        '<BBBBIHH20x',
        0x03,
        now.year - 1900,
        now.month,
        now.day,
        0,
        HEADER_LEN,
        RECORD_LEN,
    )
    field_def = lambda name: (
        name.encode('ascii').ljust(11, b'\x00')
        + b'C'
        + b'\x00\x00\x00\x00'
        + bytes([30])
        + b'\x00'
        + b'\x00' * 14
    )
    with open(path, 'wb') as f:
        f.write(header)
        f.write(field_def('WORD'))
        f.write(field_def('LEMMA'))
        f.write(b'\r')  # header terminator


def _read_header(f):
    f.seek(0)
    version, yy, mm, dd, count, hlen, rlen = struct.unpack('<BBBBIHH20x', f.read(32))
    return count, hlen, rlen


def _update_count(f, count):
    f.seek(4)
    f.write(struct.pack('<I', count))


def search_by_word(path, word):
    padded = word[:30].ljust(30)
    with open(path, 'r+b') as f:
        count, hlen, rlen = _read_header(f)
        f.seek(hlen)
        for _ in range(count):
            record = f.read(rlen)
            rec_word = record[1:31].decode('utf-8')
            if rec_word == padded:
                lemma = record[31:61].decode('utf-8')
                return lemma.rstrip()
        # append new record
        f.seek(0, os.SEEK_END)
        f.write(b' ' + padded.encode('utf-8') + padded.encode('utf-8'))
        count += 1
        _update_count(f, count)
    return word


# --- tests ---

def test_search_by_word(tmp_path):
    dbf = tmp_path / 'diclemms.dbf'
    create_dbf(dbf)

    # new word should be added
    assert search_by_word(dbf, 'hello') == 'hello'
    assert _read_header(open(dbf, 'rb'))[0] == 1

    # change lemma manually
    with open(dbf, 'r+b') as f:
        count, hlen, rlen = _read_header(f)
        f.seek(hlen + 1 + 30)  # lemma of first record
        f.write('hi'.ljust(30).encode('utf-8'))

    # existing word should return stored lemma
    assert search_by_word(dbf, 'hello') == 'hi'
    assert _read_header(open(dbf, 'rb'))[0] == 1

    # new second word
    assert search_by_word(dbf, 'world') == 'world'
    assert _read_header(open(dbf, 'rb'))[0] == 2
