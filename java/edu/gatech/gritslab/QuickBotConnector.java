package edu.gatech.gritslab;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.SocketException;
import java.net.UnknownHostException;

// Copyright (C) 2014, Georgia Tech Research Corporation
// see the LICENSE file included with this software

public class QuickBotConnector {
	
	private DatagramSocket udp_client_socket_;
	private String hostname_;
	private InetAddress ip_addr_;
	private int udp_port_;

	private final int SO_TIMEOUT = 500;

	public QuickBotConnector(String hostname, int port) {
		try {
			udp_client_socket_ = new DatagramSocket(port);
			udp_client_socket_.setSoTimeout(SO_TIMEOUT);
		} catch (SocketException e) {
			System.err.println("Error: Unable to create socket.");
			System.exit(-1);
		}

		hostname_ = hostname;
		try {
			ip_addr_ = InetAddress.getByName(hostname_);
		} catch (UnknownHostException e) {
			System.err.println("Error: Unknown host.");
			System.exit(-1);
		}
		udp_port_ = port;
		
	}

	public void close() {
		try {
			udp_client_socket_.setReuseAddress(true);
		} catch (SocketException e) {
			System.err.println("Error: Unable to release socket.");
		}
		udp_client_socket_.close();
	}
	
	public boolean initialize() {
		String reply = sendMessageWaitForReply("$CHECK*\n");		
		if (reply != null && reply.equals("Hello from QuickBot\n"))
			return true;
		return false;
	}
	
	public void reset() {
		sendMessage("$RESET*\n");
	}
	
	public void setMotorPWM(int right_motor_pwm, int left_motor_pwm) {
		String message = "$PWM=" + left_motor_pwm + "," + right_motor_pwm + "*\n";
		sendMessage(message);
	}
	
	public double[] getEncoderTicks() {
		String reply = sendMessageWaitForReply("$ENVAL=?*\n");
		return parseReply(reply);
	}
	
	public double[] getIREncodedValues() {
		String reply = sendMessageWaitForReply("$IRVAL=?*\n");
		return parseReply(reply);
	}
	
	public double[] parseReply(String reply) {
		if (reply != null) {
			String content = reply.substring(1, reply.length()-2); // remove [, ], and \n
			content = content.trim();			
			String[] tokens = content.split(",");
			
			double[] parsed_reply = new double[tokens.length];
			
			for (int i=0; i< tokens.length; i++) {
				String token = tokens[i].trim();
				if (!token.equals("nan")) {
					try {
						parsed_reply[i] = Double.parseDouble(tokens[i].trim());
					} catch (NumberFormatException e) {
						System.err.println("Error: unable to decode data.");
						parsed_reply[i] = Double.NaN;
					}
				} else {
					parsed_reply[i] = Double.NaN;
				}
			}
			
			return parsed_reply;
		}
		return null;
	}
	
	public void sendMessage(String message) {			
		byte[] send_buffer = message.getBytes();

		DatagramPacket send_packet = new DatagramPacket(send_buffer, send_buffer.length, ip_addr_, udp_port_);

		try {
			udp_client_socket_.send(send_packet);
		} catch (IOException e) {
			System.err.println("Error: Failed to send packet.");
		}
	}
	
	public String sendMessageWaitForReply(String message) {
		String reply = null;
		
		byte[] send_buffer = message.getBytes();
		byte[] recv_buffer = new byte[512];

		DatagramPacket send_packet = new DatagramPacket(send_buffer, send_buffer.length, ip_addr_, udp_port_);
		DatagramPacket recv_packet = new DatagramPacket(recv_buffer, recv_buffer.length);

		try {
			udp_client_socket_.send(send_packet);
		} catch (IOException e) {
			System.err.println("Error: Failed to send packet.");
		} 
		try {
			udp_client_socket_.receive(recv_packet);
			byte[] content = recv_packet.getData();
			StringBuilder reply_prototype = new StringBuilder();
			for (int i=0; i<content.length; i++) {
				reply_prototype.append((char) content[i]);
				if (content[i] == '\n') {
					break;
				}
			}
			reply = reply_prototype.toString();
			System.out.println("Info: Received (" + reply.length() + " character) message reads '" + reply + "'.");
		} catch (IOException e) {
			System.err.println("Error: Failed to receive reply.");
		}		
		return reply;
	}
}
