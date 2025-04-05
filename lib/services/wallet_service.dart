import 'dart:async';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletService {
  static const int MAX_RETRIES = 3;

  // Web3 클라이언트
  late final Web3Client _ethClient;

  // 지갑 주소 캐시
  String? _metamaskAddress;
  String? _solanaAddress;

  // RPC URL
  static const String _ethRpcUrl =
      'https://mainnet.infura.io/v3/YOUR_INFURA_KEY';

  WalletService() {
    _ethClient = Web3Client(_ethRpcUrl, Client());
  }

  Future<String> getMetamaskAddress() async {
    if (_metamaskAddress != null) return _metamaskAddress!;

    try {
      // 브라우저에서 이더리움 객체 확인
      final ethereum = await _getEthereum();
      if (ethereum == null) {
        throw WalletException('MetaMask not found. Please install MetaMask.');
      }

      // 계정 접근 권한 요청
      final List<String> accounts = await _requestAccounts(ethereum);

      if (accounts.isEmpty) {
        throw WalletException('No MetaMask accounts found');
      }

      _metamaskAddress = accounts.first;
      return _metamaskAddress!;
    } catch (e) {
      throw WalletException('Failed to connect to MetaMask: $e');
    }
  }

  Future<String> getSolanaAddress() async {
    if (_solanaAddress != null) return _solanaAddress!;

    try {
      // Phantom 웹사이트로 리다이렉트
      final phantomUrl = Uri.parse('https://phantom.app/');
      if (await canLaunchUrl(phantomUrl)) {
        await launchUrl(phantomUrl);
      }

      return _solanaAddress!;
    } catch (e) {
      throw WalletException('Failed to connect to Solana wallet: $e');
    }
  }

  Future<dynamic> _getEthereum() async {
    try {
      // window.ethereum 객체 접근
      final ethereum = await _evaluateJavascript('window.ethereum');
      return ethereum;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> _requestAccounts(dynamic ethereum) async {
    try {
      final accounts = await _evaluateJavascript(
        'window.ethereum.request({ method: "eth_requestAccounts" })',
      );
      return List<String>.from(accounts);
    } catch (e) {
      throw WalletException('Failed to request accounts: $e');
    }
  }

  Future<dynamic> _evaluateJavascript(String code) async {
    // 자바스크립트 실행을 위한 유틸리티 메서드
    // 실제 구현은 플랫폼에 따라 다르게 처리 필요
    throw UnimplementedError('Platform-specific implementation required');
  }

  // 재시도 로직이 포함된 일반적인 요청 처리
  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < MAX_RETRIES) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts == MAX_RETRIES) rethrow;
        await Future.delayed(Duration(seconds: attempts));
      }
    }
    throw WalletException('Max retry attempts reached');
  }

  void dispose() {
    _ethClient.dispose();
  }
}

class WalletException implements Exception {
  final String message;
  WalletException(this.message);

  @override
  String toString() => 'WalletException: $message';
}
