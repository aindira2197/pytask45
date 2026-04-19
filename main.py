class RetryMechanism:
    def __init__(self, max_retries, delay):
        self.max_retries = max_retries
        self.delay = delay

    def retry(self, func):
        def wrapper(*args, **kwargs):
            retries = 0
            while retries <= self.max_retries:
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    print(f"Error occurred: {e}")
                    retries += 1
                    if retries <= self.max_retries:
                        print(f"Retrying in {self.delay} seconds...")
                        import time
                        time.sleep(self.delay)
                    else:
                        print("Max retries exceeded. Giving up.")
                        raise
        return wrapper

def connect_to_database():
    import random
    if random.random() < 0.5:
        raise Exception("Database connection failed")
    else:
        return "Connected to database"

retry_mechanism = RetryMechanism(3, 2)
retry_connect = retry_mechanism.retry(connect_to_database)
print(retry_connect())

def send_request():
    import random
    if random.random() < 0.5:
        raise Exception("Request failed")
    else:
        return "Request sent successfully"

retry_mechanism = RetryMechanism(2, 1)
retry_send = retry_mechanism.retry(send_request)
print(retry_send())

def read_file():
    import random
    if random.random() < 0.5:
        raise Exception("File read failed")
    else:
        return "File read successfully"

retry_mechanism = RetryMechanism(4, 3)
retry_read = retry_mechanism.retry(read_file)
print(retry_read())

def write_file():
    import random
    if random.random() < 0.5:
        raise Exception("File write failed")
    else:
        return "File written successfully"

retry_mechanism = RetryMechanism(5, 4)
retry_write = retry_mechanism.retry(write_file)
print(retry_write())