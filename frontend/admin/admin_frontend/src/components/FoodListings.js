import React from 'react';
import GenericCategoryListings from './GenericCategoryListings';

const FOOD_FIELDS = {
  title: 'name',
  subKey: 'restaurantName',
  subLabel: 'RESTAURANT',
  rows: [
    ['Name', 'name'],
    ['Restaurant', 'restaurantName'],
    ['Cuisine', 'cuisine'],
    ['City', 'city'],
    ['Area', 'area'],
    ['Postal Code', 'postalCode'],
    ['Address', 'address'],
    ['Contact Phone', 'contactPhone'],
    ['Price Range', 'priceRange'],
    ['Opening Hours', 'openingHours'],
    ['Description', 'description'],
    ['Features / Amenities', 'amenities'],
    ['Status', 'status'],
  ],
};

export default function FoodListings() {
  return (
    <GenericCategoryListings
      category="Food"
      apiBase="http://10.166.137.12:5000/api/food/admin"
      icon="🍴"
      viewFields={FOOD_FIELDS}
    />
  );
}
