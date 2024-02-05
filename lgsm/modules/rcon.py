#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# LinuxGSM rcon.py module
# Author: MicLieg
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Allows sending RCON commands to different gameservers.

import argparse
import socket
import struct
import sys


class PacketTypes:
    LOGIN = 3
    COMMAND = 2


class Rcon:

    def __init__(self, arguments):
        self.arguments = arguments
        self.connection = None

    def __enter__(self):
        self.connect_to_server()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.connection:
            self.connection.close()

    @staticmethod
    def fatal_error(error_message, error_code):
        sys.stderr.write(f'ERROR: {error_code} {error_message}\n')
        sys.exit(error_code)

    @staticmethod
    def exit_success(success_message=''):
        sys.stdout.write(f'OK: {success_message}\n')
        sys.exit(0)

    def connect_to_server(self):
        self.connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.connection.settimeout(self.arguments.timeout)

        try:
            self.connection.connect((self.arguments.address, self.arguments.port))
        except socket.timeout:
            self.fatal_error('Request timed out', 1)
        except Exception as e:
            self.fatal_error(f'Unable to connect: {e}', 1)

    def send_packet(self, request_id, packet_type, data):
        # Packet structure follows the Source RCON Protocol: size, request ID, type, data, two null bytes
        packet = (
                struct.pack('<l', request_id)
                + struct.pack('<l', packet_type)
                + data.encode('utf8') + b'\x00\x00'
        )
        try:
            self.connection.send(struct.pack('<l', len(packet)) + packet)
        except socket.error as e:
            self.fatal_error(f'Failed to send packet: {e}', 2)

    def receive_packet(self):
        try:
            response = self.connection.recv(self.arguments.buffer)
            return response
        except socket.error as e:
            self.fatal_error(f'Failed to receive response: {e}', 3)

    def login(self):
        self.send_packet(1, PacketTypes.LOGIN, self.arguments.password)
        response = self.receive_packet()
        if response:
            size, id_response, type_response = struct.unpack('<l', response[:4]), struct.unpack('<l', response[
                                                                                                      4:8]), struct.unpack(
                '<l', response[8:12])

            if id_response[0] == -1:
                self.fatal_error('Login to RCON failed', 4)
        else:
            self.fatal_error('No response received for login', 4)

    def send_command(self):
        self.send_packet(2, PacketTypes.COMMAND, self.arguments.command)
        response = self.receive_packet()
        if response:
            response_message = response[12:-2].decode('utf-8')  # Stripping trailing null bytes
            self.exit_success(str(response_message))
        else:
            self.fatal_error('No response received for command', 5)


def parse_args():
    parser = argparse.ArgumentParser(description='Sends RCON commands to Minecraft servers.')
    parser.add_argument('-a', '--address', type=str, required=True, help='The server IP address.')
    parser.add_argument('-p', '--port', type=int, required=True, help='The server port.')
    parser.add_argument('-P', '--password', type=str, required=True, help='The RCON password.')
    parser.add_argument('-c', '--command', type=str, required=True, help='The RCON command to send.')
    parser.add_argument('-t', '--timeout', type=int, default=5, help='The timeout for server response.')
    parser.add_argument('-b', '--buffer', type=int, default=4096, help='The buffer length for server response.')
    return parser.parse_args()


def main():
    arguments = parse_args()
    with Rcon(arguments) as rcon:
        rcon.login()
        rcon.send_command()


if __name__ == '__main__':
    main()
