CREATE TABLE retry_mechanism (
  id INT PRIMARY KEY,
  task_id INT,
  attempt_number INT,
  status VARCHAR(50),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE tasks (
  id INT PRIMARY KEY,
  task_name VARCHAR(100),
  task_type VARCHAR(50),
  status VARCHAR(50),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE task_history (
  id INT PRIMARY KEY,
  task_id INT,
  attempt_number INT,
  status VARCHAR(50),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

INSERT INTO tasks (id, task_name, task_type, status, created_at, updated_at)
VALUES (1, 'Task 1', 'Type 1', 'pending', NOW(), NOW());

INSERT INTO retry_mechanism (id, task_id, attempt_number, status, created_at, updated_at)
VALUES (1, 1, 1, 'pending', NOW(), NOW());

CREATE PROCEDURE retry_task()
BEGIN
  DECLARE task_id INT;
  DECLARE attempt_number INT;
  DECLARE max_attempts INT;
  SET max_attempts = 5;

  SELECT id, attempt_number INTO task_id, attempt_number FROM retry_mechanism WHERE status = 'pending' LIMIT 1;

  IF task_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No tasks to retry';
  END IF;

  IF attempt_number >= max_attempts THEN
    UPDATE retry_mechanism SET status = 'failed' WHERE id = task_id;
    INSERT INTO task_history (task_id, attempt_number, status, created_at, updated_at) VALUES (task_id, attempt_number, 'failed', NOW(), NOW());
  ELSE
    UPDATE retry_mechanism SET attempt_number = attempt_number + 1, status = 'pending' WHERE id = task_id;
    INSERT INTO task_history (task_id, attempt_number, status, created_at, updated_at) VALUES (task_id, attempt_number, 'retrying', NOW(), NOW());
  END IF;
END;

CREATE EVENT retry_event
ON SCHEDULE EVERY 1 MINUTE
DO
CALL retry_task();

CREATE TRIGGER retry_trigger
AFTER INSERT ON tasks
FOR EACH ROW
BEGIN
  INSERT INTO retry_mechanism (task_id, attempt_number, status, created_at, updated_at) VALUES (NEW.id, 1, 'pending', NOW(), NOW());
END;

CREATE VIEW task_status AS
SELECT t.id, t.task_name, t.status, rm.attempt_number, rm.status AS retry_status
FROM tasks t
LEFT JOIN retry_mechanism rm ON t.id = rm.task_id;

CREATE INDEX idx_task_id ON retry_mechanism (task_id);

CREATE INDEX idx_attempt_number ON retry_mechanism (attempt_number);

CREATE INDEX idx_status ON retry_mechanism (status);

CREATE INDEX idx_task_id_history ON task_history (task_id);

CREATE INDEX idx_attempt_number_history ON task_history (attempt_number);

CREATE INDEX idx_status_history ON task_history (status);