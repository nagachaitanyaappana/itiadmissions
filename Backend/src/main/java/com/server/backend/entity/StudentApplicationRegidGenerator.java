package com.server.backend.entity;

import java.sql.ResultSet;
import java.sql.Statement;

import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.id.IdentifierGenerator;

/**
 * {@code public.student_application.regid} is {@code integer} with default
 * {@code nextval('"application_Registration_id_seq"')} in the reference schema. The sequence
 * name is mixed-case, so it must stay double-quoted inside the nextval literal (an unquoted
 * name folds to lowercase and the lookup fails). A plain SEQUENCE generator cannot guarantee
 * that quoting, hence this generator.
 */
public class StudentApplicationRegidGenerator implements IdentifierGenerator {

    private static final String NEXT_VAL_SQL =
            "select nextval('\"application_Registration_id_seq\"')";

    @Override
    public Object generate(SharedSessionContractImplementor session, Object obj) {
        return session.doReturningWork(connection -> {
            try (Statement statement = connection.createStatement();
                    ResultSet rs = statement.executeQuery(NEXT_VAL_SQL)) {
                rs.next();
                return rs.getInt(1);
            }
        });
    }
}
