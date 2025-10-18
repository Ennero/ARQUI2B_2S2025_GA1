def parse_serial_data(line: str) -> dict:
    """
    Converts a string of serial data (e.g. 'KEY1=V1;KEY2=V2') into a Python dictionary.
    Handles potential formatting errors.
    """
    state_dict = {}
    parts = line.strip().split(';')
    for part in parts:
        if '=' in part:
            try:
                key, value = part.split('=', 1)
                state_dict[key.strip()] = value.strip()
            except ValueError:
                pass
    return state_dict