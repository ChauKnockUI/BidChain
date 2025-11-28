# My Activity Screen - Integration Guide

## Overview

The My Activity screen has been fully implemented with clean architecture and BLoC pattern. This guide shows how to integrate and use the screen in your app.

## What Was Created

### Data Layer

- ✅ `MyAuctionModel` - Model for user's auctions
- ✅ `MyBidModel` - Model for user's bids
- ✅ `MyActivityRemoteDataSource` - API calls to backend
- ✅ `MyActivityRepositoryImpl` - Repository implementation

### Domain Layer

- ✅ `MyAuctionEntity` - Domain entity for auctions
- ✅ `MyBidEntity` - Domain entity for bids
- ✅ `MyActivityRepository` - Repository interface

### BLoC Layer

- ✅ `MyActivityBloc` - State management
- ✅ `MyActivityEvent` - Events (LoadMyAuctions, LoadMyBids, RefreshMyActivity)
- ✅ `MyActivityState` - States (Initial, Loading, Loaded, Error)

### UI Components

- ✅ `MyActivityPage` - Main page with TabBar
- ✅ `MyAuctionsTab` - Tab for user's auctions
- ✅ `MyBidsTab` - Tab for user's bids
- ✅ `MyAuctionCard` - Card component for auctions
- ✅ `MyBidCard` - Card component for bids
- ✅ `StatusBadge` - Reusable status badge
- ✅ `EmptyState` - Reusable empty state widget

## How to Use

### Option 1: Using BlocProvider (Recommended for single page)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'presentation/pages/my_activity/my_activity_page.dart';

// Navigate to My Activity page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => InjectionContainer.getMyActivityBloc(),
      child: const MyActivityPage(),
    ),
  ),
);
```

### Option 2: Add to MultiBlocProvider (For app-wide access)

Update `main.dart`:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              InjectionContainer.getAuthBloc()
                ..add(const AuthCheckStatusEvent()),
        ),
        // Add MyActivityBloc here
        BlocProvider<MyActivityBloc>(
          create: (context) => InjectionContainer.getMyActivityBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'BidChain',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
```

Then navigate simply:

```dart
Navigator.pushNamed(context, '/my-activity');
```

### Option 3: Add to Route Configuration

If using go_router or similar, add the route:

```dart
GoRoute(
  path: '/my-activity',
  builder: (context, state) => BlocProvider(
    create: (context) => InjectionContainer.getMyActivityBloc(),
    child: const MyActivityPage(),
  ),
),
```

## Features

### Tab 1: "Đấu giá của tôi" (My Auctions)

- Shows all auctions created by the user
- Displays auction status with color-coded badges:
  - 🟡 Chờ duyệt (PENDING_APPROVAL)
  - 🔵 Đã duyệt (APPROVED)
  - 🟢 Đang diễn ra (ACTIVE)
  - ⚫ Đã kết thúc (ENDED)
  - 🟢 Đã thanh toán (SETTLED)
  - 🔴 Bị từ chối (REJECTED)
- Shows start price, current price, time remaining
- Pull-to-refresh functionality
- Empty state with "Create Auction" button

### Tab 2: "Bid của tôi" (My Bids)

- Shows all auctions the user has bid on
- Displays bid status:
  - 🟢 Đang thắng (Winning) - User's bid is highest
  - 🟡 Bị vượt giá (Outbid) - Someone bid higher
  - 🏆 Thắng (Winner badge) - User won the auction
- Shows user's bid vs current price
- Pull-to-refresh functionality
- Empty state with "Explore Auctions" button

## API Endpoints Used

The screen uses these backend endpoints (already implemented):

- `GET /user/me/auctions` - Get user's auctions
- `GET /user/me/bids` - Get user's bids

Both endpoints require authentication (JWT token).

## Styling

The screen follows the existing design system:

- **Colors**: Cream (#F1F3E0), Sage (#A1BC98), Olive (#778873)
- **Font**: Lexend (via Google Fonts)
- **Components**: Consistent with existing auction cards and UI elements

## Testing

To test the screen:

1. **Start backend server**:

   ```bash
   cd backend
   npm run dev
   ```

2. **Run Flutter app**:

   ```bash
   cd frontend
   flutter run
   ```

3. **Login** with a user account

4. **Navigate** to My Activity page

5. **Test scenarios**:
   - Create some auctions to see in "Đấu giá của tôi"
   - Place bids on auctions to see in "Bid của tôi"
   - Pull down to refresh
   - Tap on cards to navigate to details
   - Test empty states (new user with no data)

## Troubleshooting

### "Failed to fetch my auctions/bids"

- Ensure backend server is running
- Check that user is logged in (JWT token is valid)
- Verify API base URL is correct in `ApiConstants`

### Empty states not showing

- Verify user has no auctions/bids in database
- Check that empty state widgets are rendering correctly

### BLoC not updating

- Ensure BLoC is provided correctly via BlocProvider
- Check that events are being dispatched
- Verify repository is returning data correctly

## Next Steps

Potential enhancements:

- Add filtering by status
- Add search functionality
- Add sorting options (by date, price, etc.)
- Add pagination for large lists
- Add real-time updates via WebSocket
- Add analytics/statistics view
