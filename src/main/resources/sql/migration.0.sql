CREATE TABLE IF NOT EXISTS bs_player
(
    pid                BIGINT AUTO_INCREMENT PRIMARY KEY,
    name               VARCHAR(16),
    uuid               CHAR(36)  NOT NULL UNIQUE,
    first_add          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bid                BIGINT,
    ip_pardon_time     TIMESTAMP NULL,
    proxy_pardon_time  TIMESTAMP NULL,
    shared_pardon_time TIMESTAMP NULL,
    INDEX bs_player_name (name),
    INDEX bs_player_ip_pardons (ip_pardon_time),
    INDEX bs_player_proxy_pardons (proxy_pardon_time),
    INDEX bs_player_shared_pardons (shared_pardon_time),
    INDEX bs_player_join (first_add)
);

CREATE TABLE IF NOT EXISTS bs_session
(
    sid        BIGINT AUTO_INCREMENT PRIMARY KEY,
    pid        BIGINT REFERENCES bs_player (pid),
    join_time  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    leave_time TIMESTAMP NULL,
    iid        BIGINT    NOT NULL,
    INDEX bs_session_pids (pid, join_time, leave_time)
);


CREATE TABLE IF NOT EXISTS bs_ban_log
(
    lid         BIGINT AUTO_INCREMENT PRIMARY KEY,
    pid         BIGINT      NOT NULL REFERENCES bs_player (pid),
    bid         BIGINT      NOT NULL,
    action_time TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    action      VARCHAR(10) NOT NULL,
    INDEX bs_ban_log_time (pid, action_time DESC)
);

CREATE TABLE IF NOT EXISTS bs_share
(
    sid         BIGINT AUTO_INCREMENT PRIMARY KEY,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    first_pid   BIGINT    NOT NULL REFERENCES bs_player (pid),
    second_pid  BIGINT    NOT NULL REFERENCES bs_player (pid),
    first_sid   BIGINT    NOT NULL REFERENCES bs_session (sid),
    second_sid  BIGINT    NOT NULL REFERENCES bs_session (sid),
    pardon      BOOLEAN            DEFAULT FALSE,
    pardon_time TIMESTAMP NULL,
    INDEX bs_share (first_pid, second_pid),
    INDEX bs_pardon (pardon_time)
);

CREATE TABLE IF NOT EXISTS bs_ip
(
    iid         BIGINT AUTO_INCREMENT PRIMARY KEY,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip4         CHAR(15),
    ip4cidr     SMALLINT,
    ip6         CHAR(39),
    ip6cidr     SMALLINT,
    INDEX bs_session_ip4 (ip4, ip4cidr),
    INDEX bs_session_ip6 (ip6, ip6cidr)
);

CREATE TABLE IF NOT EXISTS bs_ip_data
(
    idid          BIGINT AUTO_INCREMENT PRIMARY KEY,
    iid           BIGINT    NOT NULL REFERENCES bs_ip (iid),
    create_time   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid         BOOLEAN            DEFAULT TRUE,
    continent     TEXT,
    country       TEXT,
    region        TEXT,
    city          TEXT,
    postal        TEXT,
    lat           DOUBLE             DEFAULT NULL,
    lon           DOUBLE             DEFAULT NULL,
    domain        TEXT,
    provider      TEXT,
    registered_as TEXT,
    connection    TEXT,
    proxy         FLOAT,
    source        TEXT,
    comment       TEXT,
    INDEX bs_ip_data_iid (iid),
    INDEX bs_ip_data_valid (valid, create_time DESC),
    INDEX bs_ip_data_proxy (proxy)
);

CREATE TABLE IF NOT EXISTS bs_ban
(
    bid       BIGINT AUTO_INCREMENT PRIMARY KEY,
    ban_time  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_ban    BIGINT REFERENCES bs_ip (iid),
    proxy_ban BIGINT REFERENCES bs_ip_data (idid),
    share_ban BIGINT REFERENCES bs_share (sid),
    admin_ban BOOLEAN            DEFAULT FALSE,
    message   TEXT,
    ban_end   TIMESTAMP NULL,
    INDEX bs_ban_time (ban_time),
    INDEX bs_ban_ip (ip_ban),
    INDEX bs_ban_proxy (proxy_ban),
    INDEX bs_ban_share (share_ban),
    INDEX bs_ban_end (ban_end)
);

ALTER TABLE bs_player
    ADD CONSTRAINT bs_player_fk1 FOREIGN KEY (bid) REFERENCES bs_ban (bid);

ALTER TABLE bs_session
    ADD CONSTRAINT bs_session_fk1 FOREIGN KEY (iid) REFERENCES bs_ip (iid);

ALTER TABLE bs_ban_log
    ADD CONSTRAINT bs_ban_log_fk1 FOREIGN KEY (bid) REFERENCES bs_ban (bid);
