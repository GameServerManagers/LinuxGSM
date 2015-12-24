#! /usr/bin/env python
# -*- coding: utf-8 -*-
# Game Server Query
# Author: Anonymous & Daniel Gibbs
# # Website: http://gameservermanagers.com
# Version: 030515

import optparse
import socket
import sys

class GameServer:
	def __init__( self, options, arguments ):
		self.option = options
		self.argument = arguments
		#
		self.server_response_timeout = 5
		self.default_buffer_length = 1024
		#
		if self.option.engine == 'source':
			self.query_prompt_string = '\xFF\xFF\xFF\xFFTSource Engine Query\0'
		if self.option.engine == 'goldsource':
			self.query_prompt_string = '\xFF\xFF\xFF\xFFTSource Engine Query\0'
		if self.option.engine == 'spark':
			self.query_prompt_string = '\xFF\xFF\xFF\xFFTSource Engine Query\0'
		if self.option.engine == 'realvirtuality':
			self.query_prompt_string = '\xFF\xFF\xFF\xFFTSource Engine Query\0'
		if self.option.engine == 'unity3d':
			self.query_prompt_string = '\xFF\xFF\xFF\xFFTSource Engine Query\0'
		elif self.option.engine == 'unreal':
			self.query_prompt_string = '\x5C\x69\x6E\x66\x6F\x5C'
		elif self.option.engine == 'unreal2':
			self.query_prompt_string = '\x79\x00\x00\x00\x00'
		elif self.option.engine == 'avalanche':
			self.query_prompt_string = '\xFE\xFD\x09\x10\x20\x30\x40'
		self.connected = False
		self.response = None
		self.sanity_checks()

	def fatal_error( self, error_message, error_code=1 ):
		sys.stderr.write( 'ERROR: ' + str(error_message) + '\n' )
		sys.exit( error_code )

	def exit_success( self, success_message='' ):
		sys.stdout.write( 'OK: ' + str(success_message) + '\n' )
		sys.exit( 0 )

	def responding( self ):
		# Connect.
		connection = socket.socket( socket.AF_INET, socket.SOCK_DGRAM )
		connection.settimeout( self.server_response_timeout )
		try:
			self.connected = connection.connect( ( self.option.address, int(self.option.port) ) )
		except socket.timeout:
			self.fatal_error( 'Request timed out', 1 )
		except:
			self.fatal_error( 'Unable to connect', 1 )
		# Send.
		connection.send( self.query_prompt_string )
		# Receive.
		try:
			self.response = connection.recv( self.default_buffer_length )
		except socket.error:
			self.fatal_error( 'Unable to receive', 2 )
		connection.close()
		# Response.
		if self.response == None:
			self.fatal_error( 'No response', 3 )
		if len( self.response ) < 10 :
			sys.exit( 'Short response.', 3 )
		else:
			self.exit_success( str( self.response ) )

	def sanity_checks( self ):
		if not self.option.address:
			self.fatal_error( 'No IPv4 address supplied.', 4 )
		if not self.option.port:
			self.fatal_error( 'No port supplied.', 4 )

if __name__ == '__main__':
	parser = optparse.OptionParser(
		usage = 'usage: python %prog [options]',
		version = '%prog 0.0.1'
	)
	parser.add_option(
		'-a', '--address',
		action = 'store',
		dest = 'address',
		default = False,
		help = 'The IPv4 address of the server.'
	)
	parser.add_option(
		'-p', '--port',
		action = 'store',
		dest = 'port',
		default = False,
		help = 'The IPv4 port of the server.'
	)
	parser.add_option(
		'-e', '--engine',
		action = 'store',
		dest = 'engine',
		default = False,
		help = 'Engine type: avalanche, goldsource, realvirtuality, spark, source, unity3d, unreal, unreal2.'
	)
	parser.add_option(
		'-v', '--verbose',
		action = 'store_true',
		dest = 'verbose',
		default = False,
		help = 'Display verbose output.'
	)
	parser.add_option(
		'-d', '--debug',
		action = 'store_true',
		dest = 'debug',
		default = False,
		help = 'Display debugging output.'
	)
	options, arguments = parser.parse_args()
	#
	server = GameServer( options, arguments )
	server.responding()
