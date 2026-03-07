import React from 'react';
import GenericCategoryListings from './GenericCategoryListings';

const JOBS_FIELDS = {
  title: 'jobTitle',
  subKey: 'company',
  subLabel: 'COMPANY',
  rows: [
    ['Job Title', 'jobTitle'],
    ['Company', 'company'],
    ['Job Type', 'jobType'],
    ['City', 'city'],
    ['Area', 'area'],
    ['Address', 'address'],
    ['Contact Phone', 'contactPhone'],
    ['Salary', 'salary'],
    ['Skills', 'skills'],
    ['Description', 'description'],
    ['Status', 'status'],
  ],
};

export default function JobsListings() {
  return (
    <GenericCategoryListings
      category="Jobs"
      apiBase="https://german-bharatham-admin-2rhc.onrender.com/api/jobs/admin"
      icon="💼"
      viewFields={JOBS_FIELDS}
    />
  );
}
