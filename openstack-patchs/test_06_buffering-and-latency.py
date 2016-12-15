#
# Dataplane Automated Testing System
#
# Copyright (c) 2015-2016, Intel Corporation.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#   * Neither the name of Intel Corporation nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

from time import sleep
import logging

import dats.test.binsearch
import dats.utils as utils
import dats.config as config
import dats.plot
import dats.rstgen as rst

class ImpairDelay(dats.test.binsearch.BinarySearch):
    """Buffering and latency

    This test measures the impact of the condition when packets get buffered,
    thus they stay in memory for the extended period of time.

    Note: for buffering 125ms worth of packets at 10GbE link speed this test
    requires 4GB of RAM to be available for the application on the SUT.
    The test runs only on the first port of the SUT.

    The KPI in this test is the maximum number of packets that can be forwarded
    given the requirement that the latency of each packet is at least
    125 millisecond.
    Packets are forwarded without being modified.
    """
    def update_kpi(self, result):
        if result['pkt_size'] != 64:
            return

        self._kpi = '{:.2f} Mpps'.format(result['measurement'])

    def lower_bound(self, pkt_size):
        return 0.0

    def upper_bound(self, pkt_size):
        return 100.0

    def setup_class(self):
        self._tester = self.get_remote('tester').run_prox_with_config("gen_latency-1.cfg", "-e -t", "Tester")
        self._sut = self.get_remote('sut').run_prox_with_config("handle_latency-1.cfg", "-t", "SUT")

    def teardown_class(self):
        pass

    def run_test(self, pkt_size, duration, value):
        core_tx = 1
        core_rx = 2

        self._tester.stop_all()
        self._tester.reset_stats()
        self._tester.set_pkt_size([core_tx], pkt_size)
        self._tester.set_speed([core_tx], value)
        self._tester.start_all()

        # Getting statistics to calculate PPS at right speed....
        tsc_hz = self._tester.hz()
        sleep(2)
        rx_start, tx_start, tsc_start = self._tester.tot_stats()
        sleep(duration)
        # Get stats before stopping the cores. Stopping cores takes some time
        # and might skew results otherwise.
        rx_stop, tx_stop, tsc_stop = self._tester.tot_stats()

        # wait for all packets to arrive
        self._tester.stop([core_tx])
        sleep(2)
        self._tester.stop_all()

        # calculate the effective throughput in Mpps
        tx = tx_stop - tx_start
        tsc = tsc_stop - tsc_start
        mpps = tx / (tsc/float(tsc_hz)) / 1000000

        port_stats = self._tester.port_stats([0, 1])
        rx_total = port_stats[6]
        tx_total = port_stats[7]

        can_be_lost = int(tx_total * float(config.getOption('toleratedLoss')) / 100.0)
        logging.verbose("RX: %d; TX: %d; dropped: %d (tolerated: %d)", rx_total, tx_total, tx_total - rx_total, can_be_lost)

        pps = (value / 100.0) * utils.line_rate_to_pps(pkt_size, 1)
        logging.verbose("Mpps configured: %f; Mpps effective %f", (pps/1000000.0), mpps)

        return (tx_total - rx_total <= can_be_lost), mpps, 100.0*(tx_total - rx_total)/float(tx_total)

    def generate_report(self, results, prefix, dir):
        # Generate graph of results
        table = [[ 'Packet size (B)', 'Throughput (Mpps)', 'Theoretical Max (Mpps)']]
        for result in results:
            # TODO move formatting to <typeof(measurement)>.__str__
            table.append([
                result['pkt_size'],
                result['measurement'],
                round(utils.line_rate_to_pps(result['pkt_size'], 1) / 1000000, 2),
            ])
        dats.plot.bar_plot(table, dir + prefix + 'results.png')

        # Generate table
        table = [['Packet size (B)', 'Throughput (Mpps)', 'Theoretical Max (Mpps)', 'Duration (s)', 'Packet loss (%)']]
        for result in results:
            # TODO move formatting to <typeof(measurement)>.__str__
            table.append([
                result['pkt_size'],
                "{:.2f}".format(result['measurement']),
                "{:.2f}".format(round(utils.line_rate_to_pps(result['pkt_size'], 1) / 1000000, 2)),
                "{:.1f}".format(round(result['duration'], 1)),
                "{:.5f}".format(round(result['pkt_loss'], 5)) ])

        # Generate reStructuredText report
        report = ''
        report += '.. image:: ' + prefix + 'results.png\n'
        report += '\n'
        report += rst.simple_table(table)

        return report

