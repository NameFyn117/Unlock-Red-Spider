import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _running = false;

  Future<void> _killRedSpider() async {
    if (!Platform.isWindows) {
      _showMessage('仅在 Windows 上支持结束进程。');
      return;
    }

    setState(() => _running = true);
    try {
      final commands = <String>[
        'rename "C:\\Program Files (x86)\\3000soft\\Red Spider\\REDAgent.exe" REDAgent.exe1',
        'rename "C:\\Windows\\SysWOW64\\rscheck.exe" rscheck.exe1',
        'rename "C:\\Windows\\SysWOW64\\checkrs.exe" checkrs.exe1',
      ];

      final buffer = StringBuffer();
      for (final cmd in commands) {
        final r = await Process.run('cmd', ['/C', cmd]);
        if (r.exitCode == 0) {
          buffer.writeln('执行成功: $cmd');
        } else {
          final out = (r.stdout ?? '').toString();
          final err = (r.stderr ?? '').toString();
          buffer.writeln('执行失败: $cmd');
          buffer.writeln(err.isNotEmpty ? err : out);
        }
      }

      final kill = await Process.run('taskkill', ['/IM', 'REDAgent.exe', '/F']);
      if (kill.exitCode == 0) {
        buffer.writeln('已成功结束 REDAgent.exe');
      } else {
        final out = (kill.stdout ?? '').toString();
        final err = (kill.stderr ?? '').toString();
        buffer.writeln('结束 REDAgent.exe 失败: ${err.isNotEmpty ? err : out}');
      }

      final message = buffer.toString().trim();
      if (message.length > 400) {
        _showMessage('操作完成（详情较长），点击查看日志。');
        _showResultDialog(message);
      } else {
        _showMessage(message.isEmpty ? '操作完成' : message);
      }
    } catch (e) {
      _showMessage('执行命令失败: $e');
    } finally {
      setState(() => _running = false);
    }
  }

  void _showResultDialog(String text) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('操作结果'),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('删除REDAgent')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('点击按钮后将在 Windows 上运行命令并结束 REDAgent.exe'),
            ),
            ElevatedButton.icon(
              onPressed: _running ? null : _killRedSpider,
              icon: const Icon(Icons.power_settings_new),
              label: Text(_running ? '正在执行...' : '结束 REDAgent.exe'),
            ),
          ],
        ),
      ),
    );
  }
}
