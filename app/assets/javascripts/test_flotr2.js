$(function () {
        var test_flotr2_base_graph_data1 = eval("(" + $("#test-flotr2-base-graph-data1").html() + ")");
        var test_flotr2_base_graph_data2 = eval("(" + $("#test-flotr2-base-graph-data2").html() + ")");
        test_flotr2_basic_2line(document.getElementById("test-flotr2-base-graph"), test_flotr2_base_graph_data1, test_flotr2_base_graph_data2);
        test_flotr2_basic_1line(document.getElementById("test-flotr2-base-graph-friend"), test_flotr2_base_graph_data1);
        test_flotr2_basic_1line(document.getElementById("test-flotr2-base-graph-follower"), test_flotr2_base_graph_data2);
        test_flotr2_basic_1line(document.getElementById("test-flotr2-histogram1"), test-flotr2-histogram-data1);
    }
);