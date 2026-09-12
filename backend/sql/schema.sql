-- Optional: run this in phpMyAdmin (SQL tab) to create the database/tables
-- by hand. Not required - starting the FastAPI backend (uvicorn) also
-- creates these same tables automatically the first time it connects.

CREATE DATABASE IF NOT EXISTS expense_tracker_lao
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE expense_tracker_lao;

CREATE TABLE IF NOT EXISTS categories (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  icon_name    VARCHAR(50)  NOT NULL,
  color_value  INT          NOT NULL,
  type         ENUM('income', 'expense') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS transactions (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  type         ENUM('income', 'expense') NOT NULL,
  amount       DOUBLE NOT NULL,
  category_id  INT NOT NULL,
  date         DATETIME NOT NULL,
  note         VARCHAR(255) DEFAULT '',
  CONSTRAINT fk_transactions_category
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS budgets (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  category_id  INT NOT NULL,
  month        INT NOT NULL,
  year         INT NOT NULL,
  amount       DOUBLE NOT NULL,
  CONSTRAINT fk_budgets_category
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
