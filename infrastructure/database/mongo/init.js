// ============================================================================
// NoSQL & IN-MEMORY DATA STRUCTURES
// ============================================================================
// MongoDB Collections & Redis Key-Value Patterns
// ============================================================================

// ============================================================================
// MONGODB - NOTIFICATION SERVICE
// ============================================================================

// Collection: notifications
const notificationSchema = {
  _id: ObjectId,
  user_id: UUID,
  type: String, // 'ORDER_UPDATE', 'WALLET_TRANSACTION', 'PROMOTION', 'SYSTEM'
  priority: String, // 'HIGH', 'MEDIUM', 'LOW'
  
  // Content
  title: String,
  title_ar: String, // Arabic translation
  message: String,
  message_ar: String,
  
  // Data payload
  data: {
    order_id: UUID,
    amount: Number,
    transaction_id: UUID,
    action_url: String,
    // ... context-specific data
  },
  
  // Delivery channels
  channels: ['PUSH', 'SMS', 'EMAIL', 'IN_APP'],
  
  // Status
  sent: Boolean,
  sent_at: ISODate,
  read: Boolean,
  read_at: ISODate,
  
  // Tracking
  push_notification_id: String,
  sms_message_id: String,
  email_message_id: String,
  
  // Metadata
  created_at: ISODate,
  expires_at: ISODate, // auto-delete after 30 days
};

// Indexes for notifications
db.notifications.createIndex({ user_id: 1, created_at: -1 });
db.notifications.createIndex({ user_id: 1, read: 1 });
db.notifications.createIndex({ expires_at: 1 }, { expireAfterSeconds: 0 }); // TTL index

// Collection: notification_templates
const notificationTemplateSchema = {
  _id: ObjectId,
  template_name: String, // 'ORDER_CONFIRMED', 'WALLET_CREDITED', etc.
  template_type: String, // 'TRANSACTIONAL', 'PROMOTIONAL', 'SYSTEM'
  
  // Multi-language support
  languages: {
    en: {
      subject: String,
      title: String,
      body: String, // can include variables like {{order_number}}
      push_body: String,
      sms_body: String,
    },
    ar: {
      subject: String,
      title: String,
      body: String,
      push_body: String,
      sms_body: String,
    }
  },
  
  // Template configuration
  variables: ['order_number', 'amount', 'merchant_name'], // required variables
  channels: ['PUSH', 'SMS', 'EMAIL', 'IN_APP'],
  priority: String,
  
  // Status
  is_active: Boolean,
  version: Number,
  
  created_at: ISODate,
  updated_at: ISODate,
};

// Indexes for notification_templates
db.notification_templates.createIndex({ template_name: 1, version: -1 });
db.notification_templates.createIndex({ is_active: 1 });

// ============================================================================
// MONGODB - ANALYTICS SERVICE
// ============================================================================

// Collection: events (raw event stream)
const eventSchema = {
  _id: ObjectId,
  event_id: UUID,
  event_type: String, // 'ORDER_PLACED', 'WALLET_DEPOSIT', 'USER_REGISTERED'
  event_category: String, // 'USER', 'ORDER', 'WALLET', 'DRIVER'
  
  // Context
  user_id: UUID,
  session_id: UUID,
  device_id: String,
  
  // Entity references
  entity_type: String, // 'ORDER', 'TRANSACTION', 'PRODUCT'
  entity_id: UUID,
  
  // Event properties (flexible structure)
  properties: {
    order_type: String,
    amount: Number,
    merchant_id: UUID,
    payment_method: String,
    // ... any event-specific data
  },
  
  // Technical metadata
  metadata: {
    ip_address: String,
    user_agent: String,
    platform: String, // 'IOS', 'ANDROID', 'WEB'
    app_version: String,
    location: {
      latitude: Number,
      longitude: Number,
      city: String,
    }
  },
  
  timestamp: ISODate,
  processed: Boolean,
  processed_at: ISODate,
};

// Indexes for events
db.events.createIndex({ event_type: 1, timestamp: -1 });
db.events.createIndex({ user_id: 1, timestamp: -1 });
db.events.createIndex({ entity_id: 1, entity_type: 1 });
db.events.createIndex({ timestamp: -1 }); // for time-series queries
db.events.createIndex({ processed: 1 });

// Collection: metrics (aggregated metrics)
const metricSchema = {
  _id: ObjectId,
  metric_name: String, // 'daily_orders', 'hourly_revenue', 'user_retention'
  metric_type: String, // 'COUNT', 'SUM', 'AVERAGE', 'GAUGE'
  
  // Dimensions (for grouping)
  dimensions: {
    date: ISODate,
    hour: Number,
    day_of_week: Number,
    order_type: String,
    merchant_category: String,
    city: String,
    // ... any dimension for analysis
  },
  
  // Metric value
  value: Number,
  
  // Aggregation details
  aggregation_period: String, // 'HOURLY', 'DAILY', 'WEEKLY', 'MONTHLY'
  aggregation_window_start: ISODate,
  aggregation_window_end: ISODate,
  
  // Metadata
  calculated_at: ISODate,
  data_points_count: Number,
};

// Indexes for metrics
db.metrics.createIndex({ 
  metric_name: 1, 
  'dimensions.date': -1,
  aggregation_period: 1 
});
db.metrics.createIndex({ 
  'dimensions.order_type': 1, 
  'dimensions.date': -1 
});
db.metrics.createIndex({ calculated_at: -1 });

// Collection: user_analytics (user behavior tracking)
const userAnalyticsSchema = {
  _id: ObjectId,
  user_id: UUID,
  
  // User behavior metrics
  total_orders: Number,
  total_spent: Number,
  average_order_value: Number,
  
  // Engagement
  last_order_date: ISODate,
  days_since_last_order: Number,
  order_frequency: Number, // orders per month
  
  // Preferences
  favorite_merchants: [UUID],
  favorite_categories: [String],
  preferred_order_times: [Number], // hours of day
  
  // Segmentation
  user_segment: String, // 'VIP', 'REGULAR', 'AT_RISK', 'CHURNED'
  lifetime_value: Number,
  
  // Timestamps
  first_order_at: ISODate,
  updated_at: ISODate,
};

// Indexes for user_analytics
db.user_analytics.createIndex({ user_id: 1 });
db.user_analytics.createIndex({ user_segment: 1 });
db.user_analytics.createIndex({ lifetime_value: -1 });

// ============================================================================
// MONGODB - AUDIT LOGS
// ============================================================================

// Collection: audit_logs (compliance and security)
const auditLogSchema = {
  _id: ObjectId,
  
  // Action details
  action: String, // 'CREATE', 'UPDATE', 'DELETE', 'VIEW', 'APPROVE', 'REJECT'
  action_type: String, // 'WALLET_DEPOSIT', 'ORDER_CANCEL', 'USER_UPDATE'
  
  // Actor (who performed the action)
  user_id: UUID,
  user_role: String,
  user_email: String,
  
  // Target entity
  entity_type: String, // 'USER', 'ORDER', 'WALLET', 'TRANSACTION'
  entity_id: UUID,
  
  // Changes (for UPDATE actions)
  changes: {
    before: Object, // previous state
    after: Object,  // new state
    fields_changed: [String],
  },
  
  // Context
  ip_address: String,
  user_agent: String,
  session_id: UUID,
  
  // Result
  success: Boolean,
  error_message: String,
  
  // Metadata
  metadata: Object,
  timestamp: ISODate,
};

// Indexes for audit_logs
db.audit_logs.createIndex({ user_id: 1, timestamp: -1 });
db.audit_logs.createIndex({ entity_id: 1, entity_type: 1 });
db.audit_logs.createIndex({ action: 1, timestamp: -1 });
db.audit_logs.createIndex({ timestamp: -1 }); // for time-range queries

// ============================================================================
// REDIS - CACHE LAYER
// ============================================================================

// Pattern: Session Cache
// Key: session:{user_id}
// Type: Hash
// TTL: 24 hours
const sessionCacheExample = {
  key: "session:550e8400-e29b-41d4-a716-446655440000",
  type: "HASH",
  value: {
    user_id: "550e8400-e29b-41d4-a716-446655440000",
    token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    role: "CLIENT",
    phone: "+213555123456",
    last_activity: "2024-01-15T10:30:00Z"
  },
  ttl: 86400 // 24 hours in seconds
};

// Redis Commands for Session
/*
HSET session:550e8400-e29b-41d4-a716-446655440000 user_id "550e8400-e29b-41d4-a716-446655440000"
HSET session:550e8400-e29b-41d4-a716-446655440000 role "CLIENT"
EXPIRE session:550e8400-e29b-41d4-a716-446655440000 86400
HGETALL session:550e8400-e29b-41d4-a716-446655440000
*/

// Pattern: User Profile Cache
// Key: user:{user_id}
// Type: String (JSON)
// TTL: 1 hour
const userCacheExample = {
  key: "user:550e8400-e29b-41d4-a716-446655440000",
  type: "STRING",
  value: JSON.stringify({
    user_id: "550e8400-e29b-41d4-a716-446655440000",
    first_name: "Ahmed",
    last_name: "Benali",
    phone: "+213555123456",
    role: "CLIENT",
    wallet_balance: 5000.00,
    cached_at: "2024-01-15T10:30:00Z"
  }),
  ttl: 3600 // 1 hour
};

// Redis Commands for User Cache
/*
SET user:550e8400-e29b-41d4-a716-446655440000 '{"user_id":"...","first_name":"Ahmed",...}' EX 3600
GET user:550e8400-e29b-41d4-a716-446655440000
DEL user:550e8400-e29b-41d4-a716-446655440000
*/

// Pattern: Product Cache
// Key: product:{product_id}
// Type: String (JSON)
// TTL: 30 minutes
const productCacheExample = {
  key: "product:650e8400-e29b-41d4-a716-446655440099",
  type: "STRING",
  value: JSON.stringify({
    product_id: "650e8400-e29b-41d4-a716-446655440099",
    name: "Pizza Margherita",
    price: 850.00,
    merchant_id: "merchant-123",
    is_available: true,
    cached_at: "2024-01-15T10:30:00Z"
  }),
  ttl: 1800 // 30 minutes
};

// Pattern: Merchant Menu Cache
// Key: merchant:menu:{merchant_id}
// Type: String (JSON Array)
// TTL: 15 minutes
const merchantMenuCacheExample = {
  key: "merchant:menu:merchant-123",
  type: "STRING",
  value: JSON.stringify([
    { product_id: "prod-1", name: "Pizza", price: 850 },
    { product_id: "prod-2", name: "Pasta", price: 650 },
    { product_id: "prod-3", name: "Salad", price: 350 },
  ]),
  ttl: 900 // 15 minutes
};

// ============================================================================
// REDIS - GEOSPATIAL DATA (Driver Locations)
// ============================================================================

// Pattern: Real-time Driver Locations
// Key: drivers:available
// Type: Geo
const driverGeoExample = {
  key: "drivers:available",
  type: "GEO",
  // Stores driver locations as geospatial coordinates
};

// Redis Commands for Geospatial
/*
// Add driver location
GEOADD drivers:available 3.0588 36.7538 driver-123

// Find nearby drivers (within 5km)
GEORADIUS drivers:available 3.0588 36.7538 5 km WITHDIST WITHCOORD

// Get distance between two drivers
GEODIST drivers:available driver-123 driver-456 km

// Remove offline driver
ZREM drivers:available driver-123
*/

// Pattern: Driver Status
// Key: driver:status:{driver_id}
// Type: String
// TTL: No expiry (updated frequently)
const driverStatusExample = {
  key: "driver:status:driver-123",
  type: "STRING",
  value: JSON.stringify({
    driver_id: "driver-123",
    status: "AVAILABLE", // AVAILABLE, BUSY, OFFLINE
    current_order_id: null,
    latitude: 36.7538,
    longitude: 3.0588,
    last_update: "2024-01-15T10:30:00Z"
  }),
  ttl: null // updated frequently, no expiry
};

// ============================================================================
// REDIS - RATE LIMITING
// ============================================================================

// Pattern: API Rate Limiting
// Key: rate_limit:{user_id}:{endpoint}
// Type: String (Counter)
// TTL: 60 seconds (1 minute window)
const rateLimitExample = {
  key: "rate_limit:user-123:/api/orders",
  type: "STRING",
  value: "45", // number of requests in current window
  ttl: 60 // resets every minute
};

// Redis Commands for Rate Limiting
/*
// Increment counter
INCR rate_limit:user-123:/api/orders
EXPIRE rate_limit:user-123:/api/orders 60

// Check current count
GET rate_limit:user-123:/api/orders

// Rate limiting logic (max 100 requests per minute)
current_count = INCR rate_limit:user-123:/api/orders
if current_count == 1:
    EXPIRE rate_limit:user-123:/api/orders 60
if current_count > 100:
    return "RATE_LIMIT_EXCEEDED"
*/

// Pattern: Wallet Lock (for concurrent transaction safety)
// Key: wallet:lock:{wallet_id}
// Type: String
// TTL: 30 seconds
const walletLockExample = {
  key: "wallet:lock:wallet-456",
  type: "STRING",
  value: "transaction-789", // transaction ID that holds the lock
  ttl: 30 // auto-release after 30 seconds
};

// Redis Commands for Wallet Lock
/*
// Acquire lock (using SET NX - only set if not exists)
SET wallet:lock:wallet-456 transaction-789 NX EX 30

// Release lock
DEL wallet:lock:wallet-456

// Check if locked
EXISTS wallet:lock:wallet-456
*/

// ============================================================================
// REDIS - REAL-TIME PUB/SUB
// ============================================================================

// Pattern: Order Updates Channel
// Channel: order:updates:{order_id}
const orderUpdatesPubSubExample = {
  channel: "order:updates:order-123",
  message: JSON.stringify({
    order_id: "order-123",
    status: "ACCEPTED",
    timestamp: "2024-01-15T10:30:00Z",
    message: "Restaurant has accepted your order"
  })
};

// Redis Pub/Sub Commands
/*
// Publisher (Order Service)
PUBLISH order:updates:order-123 '{"order_id":"order-123","status":"ACCEPTED"}'

// Subscriber (Client App via WebSocket)
SUBSCRIBE order:updates:order-123

// Unsubscribe
UNSUBSCRIBE order:updates:order-123
*/

// Pattern: Driver Location Updates
// Channel: driver:location:{order_id}
const driverLocationPubSubExample = {
  channel: "driver:location:order-123",
  message: JSON.stringify({
    driver_id: "driver-456",
    order_id: "order-123",
    latitude: 36.7538,
    longitude: 3.0588,
    heading: 90,
    speed: 45,
    eta_minutes: 12,
    timestamp: "2024-01-15T10:30:15Z"
  })
};

// Pattern: Wallet Transaction Events
// Channel: wallet:transactions:{user_id}
const walletTransactionPubSubExample = {
  channel: "wallet:transactions:user-123",
  message: JSON.stringify({
    transaction_id: "txn-789",
    type: "DEPOSIT",
    amount: 5000.00,
    new_balance: 15000.00,
    timestamp: "2024-01-15T10:30:00Z"
  })
};

// ============================================================================
// REDIS - LEADERBOARDS & RANKINGS
// ============================================================================

// Pattern: Driver Earnings Leaderboard
// Key: leaderboard:drivers:daily:2024-01-15
// Type: Sorted Set
const driverLeaderboardExample = {
  key: "leaderboard:drivers:daily:2024-01-15",
  type: "ZSET",
  // Score = total earnings, Member = driver_id
};

// Redis Commands for Leaderboard
/*
// Add/update driver earnings
ZADD leaderboard:drivers:daily:2024-01-15 12500 driver-123
ZADD leaderboard:drivers:daily:2024-01-15 15000 driver-456

// Get top 10 drivers
ZREVRANGE leaderboard:drivers:daily:2024-01-15 0 9 WITHSCORES

// Get driver rank
ZREVRANK leaderboard:drivers:daily:2024-01-15 driver-123

// Get driver score
ZSCORE leaderboard:drivers:daily:2024-01-15 driver-123
*/

// ============================================================================
// REDIS - CACHING STRATEGY EXAMPLES
// ============================================================================

// Cache-Aside Pattern (Lazy Loading)
function getUserProfile(userId) {
  // 1. Check cache first
  const cached = redis.get(`user:${userId}`);
  
  if (cached) {
    return JSON.parse(cached); // Cache hit
  }
  
  // 2. Cache miss - fetch from database
  const user = database.query(`SELECT * FROM users WHERE user_id = $1`, [userId]);
  
  // 3. Store in cache for next time
  redis.setex(`user:${userId}`, 3600, JSON.stringify(user));
  
  return user;
}

// Cache Invalidation (Write-Through)
function updateUserProfile(userId, updates) {
  // 1. Update database
  database.query(`UPDATE users SET ... WHERE user_id = $1`, [userId]);
  
  // 2. Invalidate cache
  redis.del(`user:${userId}`);
  
  // Alternative: Update cache immediately
  // const updatedUser = database.query(`SELECT * FROM users WHERE user_id = $1`, [userId]);
  // redis.setex(`user:${userId}`, 3600, JSON.stringify(updatedUser));
}

// ============================================================================
// DATA RETENTION POLICIES
// ============================================================================

const dataRetentionPolicies = {
  // MongoDB Collections
  notifications: {
    retention: "30 days",
    implementation: "TTL index on expires_at field"
  },
  events: {
    retention: "90 days (raw), then move to cold storage",
    implementation: "Archive to S3/data warehouse"
  },
  audit_logs: {
    retention: "7 years (compliance)",
    implementation: "Archive old data to cold storage"
  },
  
  // Redis Keys
  session_cache: {
    retention: "24 hours",
    implementation: "Redis TTL (EXPIRE command)"
  },
  user_cache: {
    retention: "1 hour",
    implementation: "Redis TTL (EXPIRE command)"
  },
  rate_limit: {
    retention: "1 minute",
    implementation: "Redis TTL (EXPIRE command)"
  }
};

// ============================================================================
// SUMMARY OF DATA STORAGE STRATEGY
// ============================================================================

const storageStrategy = {
  PostgreSQL: {
    purpose: "Transactional data with strong consistency",
    use_cases: [
      "Users, orders, wallet transactions",
      "Financial records (ledger)",
      "Relational data with complex queries"
    ],
    characteristics: "ACID compliance, referential integrity"
  },
  
  MongoDB: {
    purpose: "Flexible schema, high write throughput",
    use_cases: [
      "Notifications, analytics events",
      "Audit logs, user behavior tracking",
      "Document-oriented data"
    ],
    characteristics: "Schema-less, horizontal scaling, aggregation pipelines"
  },
  
  Redis: {
    purpose: "Ultra-fast in-memory operations",
    use_cases: [
      "Session cache, hot data",
      "Real-time driver locations (geospatial)",
      "Rate limiting, pub/sub messaging",
      "Leaderboards, temporary locks"
    ],
    characteristics: "Sub-millisecond latency, volatile (with persistence options)"
  }
};

// Export for documentation
module.exports = {
  mongodb: {
    notifications: notificationSchema,
    notification_templates: notificationTemplateSchema,
    events: eventSchema,
    metrics: metricSchema,
    user_analytics: userAnalyticsSchema,
    audit_logs: auditLogSchema
  },
  redis: {
    patterns: {
      session: sessionCacheExample,
      user: userCacheExample,
      product: productCacheExample,
      merchantMenu: merchantMenuCacheExample,
      driverGeo: driverGeoExample,
      driverStatus: driverStatusExample,
      rateLimit: rateLimitExample,
      walletLock: walletLockExample
    },
    pubsub: {
      orderUpdates: orderUpdatesPubSubExample,
      driverLocation: driverLocationPubSubExample,
      walletTransactions: walletTransactionPubSubExample
    }
  },
  retention: dataRetentionPolicies,
  strategy: storageStrategy
};