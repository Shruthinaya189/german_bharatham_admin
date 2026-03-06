import React from 'react';
import GenericCategoryListings from './GenericCategoryListings';

const JOBS_FIELDS = {
  title: 'title',
  subKey: 'companyName',
  locationKey: 'location',
  contactKey: 'contact',
  subLabel: 'COMPANY',
  rows: [
    ['Job Title', 'title'],
    ['Company', 'companyName'],
    ['Job Type', 'jobType'],
    ['Location', 'location'],
    ['Area', 'area'],
    ['Address', 'address'],
    ['Contact', 'contact'],
    ['Salary', 'salary'],
    ['Requirements', 'requirements'],
    ['Description', 'description'],
    ['Status', 'status'],
  ],
};

export default function JobsListings() {
  return (
    <GenericCategoryListings
      category="Jobs"
      apiBase="http://localhost:5000/api/admin/jobs"
      icon="💼"
      viewFields={JOBS_FIELDS}
    />
  );
}
