CREATE DATABASE IF NOT EXISTS flag;

USE flag;

DROP TABLE IF EXISTS `flag_table`;
CREATE TABLE `flag_table` (
  `flag_column` VARCHAR(50) NOT NULL
);

INSERT INTO `flag_table` values("CBJS{FAKE_FLAG_FAKE_FLAG}");
