import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_app/core/asset_helper.dart';
import 'package:sms_app/core/pending_message_processor.dart';
import 'package:sms_app/network/models/sms_message.dart';
import 'package:sms_app/presentation/bloc/appointment/appointment_bloc.dart';
import 'package:sms_app/presentation/bloc/sms/sms_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  DateTime? selectedDate;
  String? selectedStatus;
  TextEditingController searchController = TextEditingController();
  List<SmsMessage> filteredMessages = [];

  void _showDatePicker() async {
    // Get current date to avoid assertion errors
    final DateTime now = DateTime.now();
    final DateTime lastDate = DateTime(now.year + 1, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _applyFilters();
    }
  }

  void _showStatusOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Booked'),
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedStatus = 'Booked';
                  });
                  _applyFilters();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Pending'),
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedStatus = 'Pending';
                  });
                  _applyFilters();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Failed'),
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedStatus = 'Failed';
                  });
                  _applyFilters();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyFilters() {
    if (context.read<SmsBloc>().state is SmsLoaded) {
      final allMessages = (context.read<SmsBloc>().state as SmsLoaded).messages;

      setState(() {
        filteredMessages =
            allMessages.where((message) {
              // Apply date filter
              bool dateMatch = true;
              if (selectedDate != null) {
                final messageDate = message.timestamp;
                dateMatch =
                    messageDate.year == selectedDate!.year &&
                    messageDate.month == selectedDate!.month &&
                    messageDate.day == selectedDate!.day;
              }

              // Apply status filter
              bool statusMatch = true;
              if (selectedStatus != null) {
                statusMatch = message.status == selectedStatus;
              }

              // Apply search filter
              bool searchMatch = true;
              if (searchController.text.isNotEmpty) {
                searchMatch =
                    message.sender.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    ) ||
                    message.content.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    );
              }

              return dateMatch && statusMatch && searchMatch;
            }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_applyFilters);

    // Register to receive app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Load messages from database
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Process any pending messages first
        context.read<SmsBloc>().add(ProcessPendingMessages());
        
        // Then load all messages
        context.read<SmsBloc>().add(RefreshMessages());
      } catch (e) {
        if (kDebugMode) {
          print("Error loading messages: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    // Clean up resources
    WidgetsBinding.instance.removeObserver(this);
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has come to the foreground - refresh the UI first
      if (mounted) {
        if (kDebugMode) {
          print('App resumed - refreshing message list');
        }
        
        // Just refresh the UI - the pending message processing 
        // will be handled by MainApp's lifecycle handler
        context.read<SmsBloc>().add(RefreshMessages());
      }
    }
  }

  // Show message details dialog
  void _showMessageDetailsDialog(BuildContext context, SmsMessage message, String timeAgo, Color statusColor) {
    // Format exact timestamp
    final timestampStr = "${message.timestamp.day}/${message.timestamp.month}/${message.timestamp.year} ${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}";
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row with avatar and sender info
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: statusColor,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.asset(
                            AssetHelper.avatar,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 15),
                      
                      // Sender info column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sender
                            Text(
                              message.sender,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            
                            const SizedBox(height: 5),
                            
                            // Time info
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            
                            Text(
                              timestampStr,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      message.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Message Content:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message.content,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  if(message.status != "Booked")...[
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await PendingMessageProcessor().validateAndProcessMessage(message);
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.red)
                          ),
                        ),
                        child: const Text(
                          'Re-book this Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.blue)
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Logo and Support
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [Image.asset(AssetHelper.logo, height: 40)]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Listening to messages.',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const Text(
                        'SMS Listener Active',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Messages Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Messages',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),

            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Date Filter Button
                    GestureDetector(
                      onTap: _showDatePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                selectedDate != null
                                    ? Colors.red
                                    : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Filter Date',
                          style: TextStyle(
                            color:
                                selectedDate != null
                                    ? Colors.red
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Clear Date Button
                    if (selectedDate != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = null;
                          });
                          _applyFilters();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Text(
                            'Clear Date',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(width: 12),

                    // Status Filter Button
                    GestureDetector(
                      onTap: _showStatusOptions,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                selectedStatus != null
                                    ? selectedStatus == 'Booked'
                                        ? Colors.green
                                        : selectedStatus == 'Pending'
                                        ? Colors.orange
                                        : Colors.red
                                    : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          selectedStatus ?? 'Filter Status',
                          style: TextStyle(
                            color:
                                selectedStatus != null
                                    ? selectedStatus == 'Booked'
                                        ? Colors.green
                                        : selectedStatus == 'Pending'
                                        ? Colors.orange
                                        : Colors.red
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Clear Status Button
                    if (selectedStatus != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedStatus = null;
                          });
                          _applyFilters();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Text(
                            'Clear Status',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Message List with BlocBuilder
            Expanded(
              child: BlocListener<AppointmentBloc, AppointmentState>(
                listener: (context, state) {
                  if(state is SuccessAppointment){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: TextStyle(color: Colors.black),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                  }

                  else if(state is ErrorAppointment){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                  }
                },
                child: BlocConsumer<SmsBloc, SmsState>(
                  listener: (context, state) {
                    if (state is SmsLoaded) {
                      setState(() {
                        filteredMessages = state.messages;
                      });
                      _applyFilters();
                    }

                    if (state is SmsCodeFormatError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  buildWhen: (previous, current) {
                    if (current is SmsCodeFormatError) {
                      return false;
                    }

                    return true;
                  },
                  builder: (context, state) {
                    if (state is SmsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SmsError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is SmsLoaded) {
                      if (filteredMessages.isEmpty) {
                        return const Center(
                          child: Text(
                            'No messages',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          // First process any pending messages
                          if (kDebugMode) {
                            print('Processing pending messages from pull-to-refresh');
                          }
                          
                          // Check if there are any Pending or Processing messages
                          final messages = (context.read<SmsBloc>().state as SmsLoaded).messages;
                          final hasPendingMessages = messages.any(
                            (msg) => msg.status == 'Pending' || msg.status == 'Processing'
                          );
                          
                          if (hasPendingMessages) {
                            // Use the bloc event to process pending messages
                            context.read<SmsBloc>().add(ProcessPendingMessages());
                            
                            // Wait a moment for processing to complete
                            await Future.delayed(const Duration(milliseconds: 800));
                          } else {
                            if (kDebugMode) {
                              print('No pending or processing messages to process');
                            }
                          }
                          
                          // Then refresh the message list
                          context.read<SmsBloc>().add(RefreshMessages());
                        },
                        child: ListView.builder(
                          itemCount: filteredMessages.length,
                          itemBuilder: (context, index) {
                            final message = filteredMessages[index];
                            final statusColor =
                                message.status == 'Booked'
                                    ? Colors.green
                                    : message.status == 'Pending'
                                    ? Colors.orange
                                    : Colors.red;

                            // Calculate time ago string
                            final now = DateTime.now();
                            final difference = now.difference(
                              message.timestamp,
                            );
                            String timeAgo;

                            if (difference.inSeconds < 60) {
                              timeAgo = '${difference.inSeconds} sec. ago';
                            } else if (difference.inMinutes < 60) {
                              timeAgo = '${difference.inMinutes} min. ago';
                            } else if (difference.inHours < 24) {
                              timeAgo = '${difference.inHours} hr. ago';
                            } else {
                              timeAgo = '${difference.inDays} days ago';
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Mark as read if not already read
                                  if (!message.isRead) {
                                    context.read<SmsBloc>().add(
                                      MarkMessageAsRead(message.id!),
                                    );
                                  }
                                  
                                  // Show message details dialog
                                  _showMessageDetailsDialog(context, message, timeAgo, statusColor);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        // Avatar with colored border
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            border: Border.all(
                                              color:
                                                  !message.isRead
                                                      ? Colors.blue
                                                      : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              23,
                                            ),
                                            child: Image.asset(
                                              AssetHelper.avatar,
                                              width: 46,
                                              height: 46,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Name and message info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                // Display actual sender
                                                message.sender,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                // Display actual message content
                                                message.content.length > 30
                                                    ? '${message.content.substring(0, 30)}...'
                                                    : message.content,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Time and status
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              timeAgo,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: statusColor,
                                                ),
                                              ),
                                              child: Text(
                                                message.status,
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    return const Center(
                      child: Text(
                        'No messages',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
