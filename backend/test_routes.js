// Test individual routes
console.log('Testing routes...');

try {
    console.log('Loading auth route...');
    const authRoute = require('./routes/auth');
    console.log('✅ Auth route loaded');
} catch (error) {
    console.log('❌ Auth route error:', error.message);
}

try {
    console.log('Loading users route...');
    const usersRoute = require('./routes/users');
    console.log('✅ Users route loaded');
} catch (error) {
    console.log('❌ Users route error:', error.message);
}

try {
    console.log('Loading categories route...');
    const categoriesRoute = require('./routes/categories');
    console.log('✅ Categories route loaded');
} catch (error) {
    console.log('❌ Categories route error:', error.message);
}

try {
    console.log('Loading products route...');
    const productsRoute = require('./routes/products');
    console.log('✅ Products route loaded');
} catch (error) {
    console.log('❌ Products route error:', error.message);
}

try {
    console.log('Loading cart route...');
    const cartRoute = require('./routes/cart');
    console.log('✅ Cart route loaded');
} catch (error) {
    console.log('❌ Cart route error:', error.message);
}

try {
    console.log('Loading orders route...');
    const ordersRoute = require('./routes/orders');
    console.log('✅ Orders route loaded');
} catch (error) {
    console.log('❌ Orders route error:', error.message);
}

try {
    console.log('Loading reviews route...');
    const reviewsRoute = require('./routes/reviews');
    console.log('✅ Reviews route loaded');
} catch (error) {
    console.log('❌ Reviews route error:', error.message);
}

console.log('Route testing completed.');