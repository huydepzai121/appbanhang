const http = require('http');

async function testLogin() {
  return new Promise((resolve, reject) => {
    const loginData = JSON.stringify({
      email: 'admin@phonestore.com',
      password: 'password'
    });

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/auth/login',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(loginData)
      }
    };

    console.log('Testing login...');

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        console.log('Login Status Code:', res.statusCode);
        console.log('Login Response:', data);

        try {
          const jsonData = JSON.parse(data);
          if (jsonData.success && jsonData.data && jsonData.data.token) {
            resolve(jsonData.data.token);
          } else {
            reject(new Error('Login failed: ' + jsonData.message));
          }
        } catch (e) {
          reject(new Error('Failed to parse login response: ' + e.message));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(loginData);
    req.end();
  });
}

async function testAdminOrders(token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/admin/orders',
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    };

    console.log('Testing admin orders endpoint with token...');

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        console.log('Orders Status Code:', res.statusCode);
        console.log('Orders Response:', data);

        try {
          const jsonData = JSON.parse(data);
          console.log('Parsed Orders JSON:', JSON.stringify(jsonData, null, 2));
          resolve(jsonData);
        } catch (e) {
          reject(new Error('Failed to parse orders response: ' + e.message));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.end();
  });
}

async function runTests() {
  try {
    const token = await testLogin();
    console.log('✅ Login successful, token received');

    const ordersResponse = await testAdminOrders(token);
    console.log('✅ Orders API test completed');

    // Check the response structure
    if (ordersResponse.success && ordersResponse.data && ordersResponse.data.orders) {
      console.log('✅ Response structure is correct');
      console.log(`Found ${ordersResponse.data.orders.length} orders`);
    } else {
      console.log('❌ Unexpected response structure');
    }

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

runTests();
