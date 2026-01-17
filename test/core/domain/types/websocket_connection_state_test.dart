import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/types/websocket_connection_state.dart';

void main() {
  group('WebSocketConnectionState', () {
    test('has all expected enum values', () {
      expect(WebSocketConnectionState.values.length, 5);
      expect(
        WebSocketConnectionState.values,
        contains(WebSocketConnectionState.disconnected),
      );
      expect(
        WebSocketConnectionState.values,
        contains(WebSocketConnectionState.connecting),
      );
      expect(
        WebSocketConnectionState.values,
        contains(WebSocketConnectionState.connected),
      );
      expect(
        WebSocketConnectionState.values,
        contains(WebSocketConnectionState.reconnecting),
      );
      expect(
        WebSocketConnectionState.values,
        contains(WebSocketConnectionState.failed),
      );
    });
  });

  group('WebSocketConnectionStateX', () {
    group('canSendMessages', () {
      test('returns true for connected state', () {
        expect(WebSocketConnectionState.connected.canSendMessages, true);
      });

      test('returns false for disconnected state', () {
        expect(WebSocketConnectionState.disconnected.canSendMessages, false);
      });

      test('returns false for connecting state', () {
        expect(WebSocketConnectionState.connecting.canSendMessages, false);
      });

      test('returns false for reconnecting state', () {
        expect(WebSocketConnectionState.reconnecting.canSendMessages, false);
      });

      test('returns false for failed state', () {
        expect(WebSocketConnectionState.failed.canSendMessages, false);
      });
    });

    group('isConnecting', () {
      test('returns true for connecting state', () {
        expect(WebSocketConnectionState.connecting.isConnecting, true);
      });

      test('returns true for reconnecting state', () {
        expect(WebSocketConnectionState.reconnecting.isConnecting, true);
      });

      test('returns false for disconnected state', () {
        expect(WebSocketConnectionState.disconnected.isConnecting, false);
      });

      test('returns false for connected state', () {
        expect(WebSocketConnectionState.connected.isConnecting, false);
      });

      test('returns false for failed state', () {
        expect(WebSocketConnectionState.failed.isConnecting, false);
      });
    });

    group('isConnected', () {
      test('returns true for connected state', () {
        expect(WebSocketConnectionState.connected.isConnected, true);
      });

      test('returns false for disconnected state', () {
        expect(WebSocketConnectionState.disconnected.isConnected, false);
      });

      test('returns false for connecting state', () {
        expect(WebSocketConnectionState.connecting.isConnected, false);
      });

      test('returns false for reconnecting state', () {
        expect(WebSocketConnectionState.reconnecting.isConnected, false);
      });

      test('returns false for failed state', () {
        expect(WebSocketConnectionState.failed.isConnected, false);
      });
    });

    group('isFailed', () {
      test('returns true for failed state', () {
        expect(WebSocketConnectionState.failed.isFailed, true);
      });

      test('returns false for disconnected state', () {
        expect(WebSocketConnectionState.disconnected.isFailed, false);
      });

      test('returns false for connecting state', () {
        expect(WebSocketConnectionState.connecting.isFailed, false);
      });

      test('returns false for connected state', () {
        expect(WebSocketConnectionState.connected.isFailed, false);
      });

      test('returns false for reconnecting state', () {
        expect(WebSocketConnectionState.reconnecting.isFailed, false);
      });
    });

    group('isDisconnected', () {
      test('returns true for disconnected state', () {
        expect(WebSocketConnectionState.disconnected.isDisconnected, true);
      });

      test('returns false for connecting state', () {
        expect(WebSocketConnectionState.connecting.isDisconnected, false);
      });

      test('returns false for connected state', () {
        expect(WebSocketConnectionState.connected.isDisconnected, false);
      });

      test('returns false for reconnecting state', () {
        expect(WebSocketConnectionState.reconnecting.isDisconnected, false);
      });

      test('returns false for failed state', () {
        expect(WebSocketConnectionState.failed.isDisconnected, false);
      });
    });

    group('displayName', () {
      test('returns correct display name for disconnected state', () {
        expect(
          WebSocketConnectionState.disconnected.displayName,
          'Disconnected',
        );
      });

      test('returns correct display name for connecting state', () {
        expect(
          WebSocketConnectionState.connecting.displayName,
          'Connecting',
        );
      });

      test('returns correct display name for connected state', () {
        expect(
          WebSocketConnectionState.connected.displayName,
          'Connected',
        );
      });

      test('returns correct display name for reconnecting state', () {
        expect(
          WebSocketConnectionState.reconnecting.displayName,
          'Reconnecting',
        );
      });

      test('returns correct display name for failed state', () {
        expect(
          WebSocketConnectionState.failed.displayName,
          'Failed',
        );
      });

      test('returns unique display names for all states', () {
        final displayNames = WebSocketConnectionState.values
            .map((state) => state.displayName)
            .toSet();

        expect(displayNames.length, WebSocketConnectionState.values.length);
      });
    });
  });
}
