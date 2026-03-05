import React from 'react';
import GenericCategoryListings from './GenericCategoryListings';

const SERVICES_FIELDS = {
  title: 'serviceName',
  subKey: 'providerName',
  subLabel: 'PROVIDER',
  rows: [
    ['Service Name', 'serviceName'],
    ['Provider', 'providerName'],
    ['Service Type', 'serviceType'],
    ['City', 'city'],
    ['Area', 'area'],
    ['Postal Code', 'postalCode'],
    ['Address', 'address'],
    ['Contact Phone', 'contactPhone'],
    ['Price Range', 'priceRange'],
    ['Description', 'description'],
    ['Status', 'status'],
  ],
};

export default function ServicesListings() {
  return (
    <GenericCategoryListings
      category="Services"
      apiBase="http://10.166.137.12:5000/api/services/admin"
      icon="🔧"
      viewFields={SERVICES_FIELDS}
    />
  );
}
