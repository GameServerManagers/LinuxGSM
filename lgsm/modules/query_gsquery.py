#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# LinuxGSM query_gsquery.py module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Allows querying of various game servers.

import argparse
import socket
import sys

engine_types = ('protocol-valve', 'protocol-quake2', 'protocol-quake3', 'protocol-gamespy1',
                'protocol-unreal2', 'ut3', 'minecraft', 'minecraftbe', 'jc2mp', 'mumbleping', 'soldat', 'teeworlds')


class gsquery:
    server_response_timeout = 2
    default_buffer_length = 1024
    sourcequery = ('protocol-valve', 'avalanche3.0', 'barotrauma', 'madness', 'quakelive', 'realvirtuality',
                   'refractor', 'source', 'goldsrc', 'spark', 'starbound', 'unity3d', 'unreal4', 'wurm')
    idtech2query = ('protocol-quake2', 'idtech2', 'quake', 'iw2.0')
    idtech3query = ('protocol-quake3', 'iw3.0', 'ioquake3', 'qfusion')
    minecraftquery = ('minecraft', 'lwjgl2')
    minecraftbequery = ('minecraftbe')
    jc2mpquery = ('jc2mp')
    mumblequery = ('mumbleping')
    soldatquery = ('soldat')
    twquery = ('teeworlds')
    unrealquery = ('protocol-gamespy1', 'unreal')
    unreal2query = ('protocol-unreal2', 'unreal2')
    unreal3query = ('ut3', 'unreal3')

    def __init__(self, arguments):
        self.argument = arguments
        #
        if self.argument.engine in self.sourcequery:
            self.query_prompt_string = b'\xFF\xFF\xFF\xFFTSource Engine Query\0'
        elif self.argument.engine in self.idtech2query:
            self.query_prompt_string = b'\xff\xff\xff\xffstatus\x00'
        elif self.argument.engine in self.idtech3query:
            self.query_prompt_string = b'\xff\xff\xff\xffgetstatus'
        elif self.argument.engine in self.jc2mpquery:
            self.query_prompt_string = b'\xFE\xFD\x09\x10\x20\x30\x40'
        elif self.argument.engine in self.minecraftquery:
            self.query_prompt_string = b'\xFE\xFD\x09\x3d\x54\x1f\x93'
        elif self.argument.engine in self.minecraftbequery:
            self.query_prompt_string = b'\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\x00\xfe\xfe\xfe\xfe\xfd\xfd\xfd\xfd\x12\x34\x56\x78\x00\x00\x00\x00\x00\x00\x00\x00'
        elif self.argument.engine in self.mumblequery:
            self.query_prompt_string = b'\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08'
        elif self.argument.engine in self.soldatquery:
            self.query_prompt_string = b'\x69\x00'
        elif self.argument.engine in self.twquery:
            self.query_prompt_string = b'\x04\x00\x00\xff\xff\xff\xff\x05' + \
                bytearray(511)
        elif self.argument.engine in self.unrealquery:
            self.query_prompt_string = b'\x5C\x69\x6E\x66\x6F\x5C'
        elif self.argument.engine in self.unreal2query:
            self.query_prompt_string = b'\x79\x00\x00\x00\x00'
        elif self.argument.engine in self.unreal3query:
            self.query_prompt_string = b'\xFE\xFD\x09\x00\x00\x00\x00'

        self.connected = False
        self.response = None

    @staticmethod
    def fatal_error(error_message, error_code=1):
        sys.stderr.write('ERROR: ' + str(error_message) + '\n')
        sys.exit(error_code)

    @staticmethod
    def exit_success(success_message=''):
        sys.stdout.write('OK: ' + str(success_message) + '\n')
        sys.exit(0)

    def responding(self):
        # Connect.
        connection = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        connection.settimeout(self.server_response_timeout)
        try:
            self.connected = connection.connect(
                (self.argument.address, int(self.argument.port)))
        except socket.timeout:
            self.fatal_error('Request timed out', 1)
        except Exception:
            self.fatal_error('Unable to connect', 1)
        # Send.
        connection.send(self.query_prompt_string)
        # Receive.
        try:
            self.response = connection.recv(self.default_buffer_length)
        except socket.error:
            self.fatal_error('Unable to receive', 2)
        connection.close()
        # Response.
        if self.response is None:
            self.fatal_error('No response', 3)
        if len(self.response) < 5:
            sys.exit('Short response.', 3)
        else:
            self.exit_success(str(self.response))


def parse_args():
    parser = argparse.ArgumentParser(
        description='Allows querying of various game servers.',
        usage='usage: python3 %(prog)s [options]',
        add_help=False
    )
    parser.add_argument(
        '-a', '--address',
        type=str,
        required=True,
        help='The IPv4 address of the server.'
    )
    parser.add_argument(
        '-p', '--port',
        type=int,
        required=True,
        help='The IPv4 port of the server.'
    )
    parser.add_argument(
        '-e', '--engine',
        metavar='ENGINE',
        choices=engine_types,
        help='Engine type: ' + ' '.join(engine_types)
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Display verbose output.'
    )
    parser.add_argument(
        '-d', '--debug',
        action='store_true',
        help='Display debugging output.'
    )
    parser.add_argument(
        '-V', '--version',
        action='version',
        version='%(prog)s 0.0.1',
        help='Display version and exit.'
    )
    parser.add_argument(
        '-h', '--help',
        action='help',
        help='Display help and exit.'
    )
    return parser.parse_args()


def main():
    arguments = parse_args()
    server = gsquery(arguments)
    server.responding()


if __name__ == '__main__':
    main()
