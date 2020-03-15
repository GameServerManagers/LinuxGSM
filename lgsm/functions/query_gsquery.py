#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# query_gsquery.py
# Author: Anonymous & Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Allows querying of various game servers.

import optparse
import socket
import sys

class gsquery:
    def __init__(self, options, arguments):
        self.option = options
        self.argument = arguments
        #
        self.server_response_timeout = 5
        self.default_buffer_length = 1024
        #
        sourcequery=['protocol-valve','avalanche3.0','barotrauma','madness','quakelive','realvirtuality','refractor','source','goldsource','spark','starbound','unity3d','unreal4','wurm']
        idtech2query=['protocol-quake3','idtech2','quake','iw2.0']
        idtech3query=['protocol-quake3','iw3.0','ioquake3','qfusion']
        minecraftquery=['minecraft','lwjgl2']
        minecraftbequery=['minecraftbe']
        jc2mpquery=['jc2mp']
        mumblequery=['mumbleping']
        twquery=['teeworlds']
        unrealquery=['protocol-gamespy1','unreal']
        unreal2query=['protocol-unreal2','unreal2']
        if self.option.engine in sourcequery:
            self.query_prompt_string = b'\xFF\xFF\xFF\xFFTSource Engine Query\0'
        elif self.option.engine in idtech2query:
            self.query_prompt_string = b'\xff\xff\xff\xffstatus\x00'
        elif self.option.engine in idtech3query:
            self.query_prompt_string = b'\xff\xff\xff\xffgetstatus'
        elif self.option.engine in jc2mpquery:
            self.query_prompt_string = b'\xFE\xFD\x09\x10\x20\x30\x40'
        elif self.option.engine in minecraftquery:
            self.query_prompt_string = b'\xFE\xFD\x09\x3d\x54\x1f\x93'
        elif self.option.engine in minecraftbequery:
            self.query_prompt_string = b'\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\x00\xfe\xfe\xfe\xfe\xfd\xfd\xfd\xfd\x12\x34\x56\x78\x00\x00\x00\x00\x00\x00\x00\x00'
        elif self.option.engine in mumblequery:
            self.query_prompt_string = b'\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08'
        elif self.option.engine in unrealquery:
            self.query_prompt_string = b'\x5C\x69\x6E\x66\x6F\x5C'
        elif self.option.engine in unreal2query:
            self.query_prompt_string = b'\x79\x00\x00\x00\x00'
        elif self.option.engine in twquery:
            self.query_prompt_string = b"\x04\x00\x00\xff\xff\xff\xff\x05" + bytearray(511)

        self.connected = False
        self.response = None
        self.sanity_checks()

    def fatal_error(self, error_message, error_code=1):
        sys.stderr.write('ERROR: ' + str(error_message) + '\n')
        sys.exit(error_code)

    def exit_success(self, success_message=''):
        sys.stdout.write('OK: ' + str(success_message) + '\n')
        sys.exit(0)

    def responding(self):
        # Connect.
        connection = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        connection.settimeout(self.server_response_timeout)
        try:
            self.connected = connection.connect((self.option.address, int(self.option.port)))
        except socket.timeout:
            self.fatal_error('Request timed out', 1)
        except:
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
        if len(self.response) < 10:
            sys.exit('Short response.', 3)
        else:
            self.exit_success(str(self.response))

    def sanity_checks(self):
        if not self.option.address:
            self.fatal_error('No IPv4 address supplied.', 4)
        if not self.option.port:
            self.fatal_error('No port supplied.', 4)

if __name__ == '__main__':
    parser = optparse.OptionParser(
        usage='usage: python3 %prog [options]',
        version='%prog 0.0.1'
    )
    parser.add_option(
        '-a', '--address',
        action='store',
        dest='address',
        default=False,
        help='The IPv4 address of the server.'
    )
    parser.add_option(
        '-p', '--port',
        action='store',
        dest='port',
        default=False,
        help='The IPv4 port of the server.'
    )
    parser.add_option(
        '-e', '--engine',
        action='store',
        dest='engine',
        default=False,
        help='Engine type: protocol-valve protocol-quake3 protocol-quake3 protocol-gamespy1 protocol-unreal2 minecraft minecraftbe jc2mp mumbleping teeworlds'
    )
    parser.add_option(
        '-v', '--verbose',
        action='store_true',
        dest='verbose',
        default=False,
        help='Display verbose output.'
    )
    parser.add_option(
        '-d', '--debug',
        action='store_true',
        dest='debug',
        default=False,
        help='Display debugging output.'
    )
    options, arguments = parser.parse_args()
    #
    server = gsquery(options, arguments)
    server.responding()
