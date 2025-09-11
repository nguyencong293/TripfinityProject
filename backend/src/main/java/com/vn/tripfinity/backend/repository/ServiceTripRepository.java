package com.vn.tripfinity.backend.repository;

import com.vn.tripfinity.backend.model.ServiceTrip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ServiceTripRepository extends JpaRepository<ServiceTrip, Integer> {

    // theo provider_id
    List<ServiceTrip> findByProvider_ProviderId(Integer providerId);

    List<ServiceTrip> findByServiceStatus(ServiceTrip.ServiceStatus status);

    List<ServiceTrip> findByServiceType(ServiceTrip.ServiceType type);
}