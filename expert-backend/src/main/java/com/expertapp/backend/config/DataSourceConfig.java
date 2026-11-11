package com.expertapp.backend.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;
import java.net.URI;

@Configuration
public class DataSourceConfig {

    private static final Logger log = LoggerFactory.getLogger(DataSourceConfig.class);

    @Value("${spring.datasource.url:jdbc:postgresql://localhost:5432/expert_db}")
    private String dbUrl;

    @Value("${spring.datasource.username:postgres}")
    private String username;

    @Value("${spring.datasource.password:}")
    private String password;

    @Bean
    @Primary
    public DataSource dataSource() {
        HikariConfig config = new HikariConfig();
        
        String cleanUrl = dbUrl;
        if (cleanUrl != null) {
            if (cleanUrl.startsWith("postgres://") || cleanUrl.startsWith("postgresql://")) {
                try {
                    URI uri = new URI(cleanUrl.replace("postgresql://", "postgres://"));
                    String host = uri.getHost();
                    int port = uri.getPort() == -1 ? 5432 : uri.getPort();
                    String path = uri.getPath();
                    if (path != null && path.startsWith("/")) {
                        path = path.substring(1);
                    }
                    if (uri.getUserInfo() != null) {
                        String[] userInfo = uri.getUserInfo().split(":");
                        if (userInfo.length > 0 && (username == null || username.isEmpty() || "postgres".equals(username))) {
                            username = userInfo[0];
                        }
                        if (userInfo.length > 1 && (password == null || password.isEmpty())) {
                            password = userInfo[1];
                        }
                    }
                    cleanUrl = "jdbc:postgresql://" + host + ":" + port + "/" + path + "?sslmode=prefer";
                    log.info("Converted cloud postgres URL to JDBC URL for host: {}:{}", host, port);
                } catch (Exception e) {
                    log.warn("Could not parse postgres URI, prepending jdbc: {}", e.getMessage());
                    cleanUrl = "jdbc:" + dbUrl;
                }
            } else if (!cleanUrl.startsWith("jdbc:")) {
                cleanUrl = "jdbc:postgresql://" + cleanUrl;
            }
        }

        config.setJdbcUrl(cleanUrl);
        config.setUsername(username);
        config.setPassword(password);
        config.setDriverClassName("org.postgresql.Driver");
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(2);
        config.setIdleTimeout(300000);
        config.setConnectionTimeout(20000);

        return new HikariDataSource(config);
    }
}

