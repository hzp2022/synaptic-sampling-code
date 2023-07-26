    Matlab Spiking Neural Network (SNN) Toolbox  Matlab脉冲神经网络（SNN）工具箱
    Copyright (C) 2015 Kappel David

    License Statement:

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


    Details to the Code:

    SNN is a small toolbox for Matlab that is designed for fast prototyping
    of spiking neural networks and models of synaptic plasticity. It
    includes functions for managing file i/o (see snn_save, snn_load),
    handing of experimental run session (see snn_switch_session), parsing
    arguments (see snn_process_options) and handling and generating generic
    network objects (see snn_new). It also includes a simple meta language
    that can be used parse information about network parameters directly
    from the documentation of a source file (see
    private/snn_parse_meta_data.m for more details).
    SNN是Matlab的一个小型工具箱，是为快速建立脉冲神经网络和突触可塑性模型而设计的。
    它包括管理文件i/o（见snn_save，snn_load），处理实验运行会话的转换（见snn_switch_session），
    解析参数（见snn_process_options）以及处理和生成通用网络对象（见snn_new）的功能。
    它还包括一个简单的元语言，可以用来直接从源文件的文档中解析网络参数的信息（更多细节见private/snn_parse_meta_data.m）。

    David Kappel, Graz, August 2015

