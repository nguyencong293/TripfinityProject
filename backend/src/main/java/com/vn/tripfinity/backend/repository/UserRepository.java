package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    @Query(
            "SELECT CASE WHEN COUNT(u) > 0 THEN true ELSE false END " +
                    "FROM User u " +
                    "WHERE u.email = :email " +
                    "  AND u.accountStatus = com.vn.tripfinity.backend.model.User.AccountStatus.active " +
                    "  AND u.accountRole NOT IN (" +
                    "    com.vn.tripfinity.backend.model.User.AccountRole.provider, " +
                    "    com.vn.tripfinity.backend.model.User.AccountRole.admin" +
                    "  )"
    )
    boolean isAllowedUser(@Param("email") String email);

    @Query(
            "SELECT CASE WHEN COUNT(u) > 0 THEN true ELSE false END " +
                    "FROM User u " +
                    "WHERE u.email = :email " +
                    "  AND u.accountStatus = com.vn.tripfinity.backend.model.User.AccountStatus.active " +
                    "  AND u.accountRole = com.vn.tripfinity.backend.model.User.AccountRole.provider"
    )
    boolean isAllowedProvider(@Param("email") String email);
}


