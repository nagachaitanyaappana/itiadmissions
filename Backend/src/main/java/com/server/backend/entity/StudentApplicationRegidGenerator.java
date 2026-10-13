package com.server.backend.entity;

import java.sql.ResultSet;
import java.sql.Statement;

import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.id.IdentifierGenerator;

/**
 * {@code public.student_application.regid} is {@code character varying} in the
 * reference schema, so the primary key maps as {@code String}. Hibernate's
 * built-in sequence generator refuses non-integral id types, hence this
 * generator: it pulls the next value from {@code student_application_regid_seq}
 * and returns it as a numeric-looking string.
 */
public class StudentApplicationRegidGenerator implements IdentifierGenerator {

    private static final String NEXT_VAL_SQL =
            "select nextval('student_application_regid_seq')";

    @Override
    public Object generate(SharedSessionContractImplementor session, Object obj) {
        return session.doReturningWork(connection -> {
            try (Statement statement = connection.createStatement();
                    ResultSet rs = statement.executeQuery(NEXT_VAL_SQL)) {
                rs.next();
                return String.valueOf(rs.getLong(1));
            }
        });
    }
}