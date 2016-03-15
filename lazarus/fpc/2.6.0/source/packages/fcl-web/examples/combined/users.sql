CREATE TABLE USERS (
U_ID BIGINT Not Null ,
U_LOGIN VARCHAR(40) Not Null,
U_NAME VARCHAR(30) Not Null,
U_EMAIL VARCHAR(100),
U_PASSWORD VARCHAR(100) Not Null,
CONSTRAINT PK_FPCUSERS Primary key (U_ID),
CONSTRAINT U_USERNAME Unique key (U_LOGIN)
);

COMMIT;

CREATE GENERATOR GEN_USERS;

COMMIT;
