const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test functions
async function testHealthCheck() {
    try {
        const response = await axios.get(`${BASE_URL}/health`);
        console.log('✅ Health check:', response.data);
        return true;
    } catch (error) {
        console.log('❌ Health check failed:', error.message);
        return false;
    }
}

async function testLogin() {
    try {
        const response = await axios.post(`${BASE_URL}/auth/login`, {
            email: 'admin@phonestore.com',
            password: 'password'
        });
        console.log('✅ Login successful');
        return response.data.data.token;
    } catch (error) {
        console.log('❌ Login failed:', error.response?.data?.message || error.message);
        return null;
    }
}

async function testGetProducts() {
    try {
        const response = await axios.get(`${BASE_URL}/products?limit=5`);
        console.log('✅ Get products:', response.data.data.items.length, 'products found');
        return true;
    } catch (error) {
        console.log('❌ Get products failed:', error.response?.data?.message || error.message);
        return false;
    }
}

async function testGetCategories() {
    try {
        const response = await axios.get(`${BASE_URL}/categories`);
        console.log('✅ Get categories:', response.data.data.length, 'categories found');
        return true;
    } catch (error) {
        console.log('❌ Get categories failed:', error.response?.data?.message || error.message);
        return false;
    }
}

async function testAuthenticatedEndpoint(token) {
    try {
        const response = await axios.get(`${BASE_URL}/auth/profile`, {
            headers: { Authorization: `Bearer ${token}` }
        });
        console.log('✅ Authenticated endpoint:', response.data.data.name);
        return true;
    } catch (error) {
        console.log('❌ Authenticated endpoint failed:', error.response?.data?.message || error.message);
        return false;
    }
}

// Main test function
async function runTests() {
    console.log('🧪 Starting API Tests...\n');

    let passedTests = 0;
    let totalTests = 0;

    // Test 1: Health check
    totalTests++;
    if (await testHealthCheck()) passedTests++;

    console.log('');

    // Test 2: Login
    totalTests++;
    const token = await testLogin();
    if (token) passedTests++;

    console.log('');

    // Test 3: Get products
    totalTests++;
    if (await testGetProducts()) passedTests++;

    console.log('');

    // Test 4: Get categories
    totalTests++;
    if (await testGetCategories()) passedTests++;

    console.log('');

    // Test 5: Authenticated endpoint
    if (token) {
        totalTests++;
        if (await testAuthenticatedEndpoint(token)) passedTests++;
    }

    console.log('\n📊 Test Results:');
    console.log(`✅ Passed: ${passedTests}/${totalTests}`);
    console.log(`❌ Failed: ${totalTests - passedTests}/${totalTests}`);

    if (passedTests === totalTests) {
        console.log('🎉 All tests passed! API is working correctly.');
    } else {
        console.log('⚠️  Some tests failed. Please check the server and database.');
    }
}

// Run tests if this file is executed directly
if (require.main === module) {
    runTests().catch(console.error);
}

module.exports = { runTests };