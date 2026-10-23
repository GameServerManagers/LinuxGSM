#!/usr/bin/env python3
"""Exercise the WON query CLI against local UDP responders."""

import concurrent.futures
import socket
import subprocess
import sys
import unittest
from pathlib import Path

QUERY = Path(__file__).resolve().parents[2] / "lgsm/modules/query_gsquery.py"
INFO = (
    b"\xff\xff\xff\xffm127.0.0.1:27015\0WON test\0crossfire\0"
    b"valve\0Half-Life\0\0\x10.dl\0\0\0\0"
)


class WonQueryTests(unittest.TestCase):
    """Check legacy queries, invalid packets and the existing Valve request."""

    def query(self, engine, response):
        """Run the CLI and capture its request through an actual UDP socket."""
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as server:
            server.bind(("127.0.0.1", 0))
            server.settimeout(5)

            def respond():
                request, address = server.recvfrom(4096)
                server.sendto(response, address)
                return request

            with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
                request = pool.submit(respond)
                result = subprocess.run(
                    [
                        sys.executable,
                        str(QUERY),
                        "-a",
                        "127.0.0.1",
                        "-p",
                        str(server.getsockname()[1]),
                        "-e",
                        engine,
                    ],
                    capture_output=True,
                    text=True,
                    timeout=5,
                    check=False,
                )
                return result, request.result(timeout=5)

    def test_won_server_info(self):
        """A protocol 46 response makes the legacy query succeed."""
        result, request = self.query("protocol-valve-won", INFO)
        self.assertEqual(request, b"\xff\xff\xff\xffdetails\0")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("crossfire", result.stdout)

    def test_unrelated_packet_fails(self):
        """An unrelated UDP listener must not pass the WON monitor."""
        result, _ = self.query("protocol-valve-won", b"unrelated UDP response")
        self.assertEqual(result.returncode, 3)

    def test_truncated_packet_fails(self):
        """The response header alone is insufficient for a healthy server."""
        result, _ = self.query("protocol-valve-won", INFO[:5])
        self.assertEqual(result.returncode, 3)

    def test_existing_valve_request(self):
        """The modern Valve query keeps its existing request format."""
        result, request = self.query("protocol-valve", b"\xff\xff\xff\xffItest")
        self.assertEqual(request, b"\xff\xff\xff\xffTSource Engine Query\0")
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
