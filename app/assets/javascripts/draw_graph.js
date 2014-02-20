function friend_gener_basic_pie(container, genders) {
    var
        d1 = [
            [0, genders['male_count']]
        ],
        d2 = [
            [0, genders['female_count']]
        ],
        graph;

    graph = Flotr.draw(container, [
        { data: d1, label: '男' },
        { data: d2, label: '女' }
    ],
        {
            grid: {
                outlineWidth: 0,
                verticalLines: false,
                horizontalLines: false
            },
            xaxis: { showLabels: false },
            yaxis: { showLabels: false },
            pie: {
                show: true,
                explode: 6
            },
            mouse: { track: true },
            legend: {
                position: 'ne',
                backgroundColor: '#D2E8FF'
            }
        }
    );
};

function friend_age_basic_pie(container, friends_age) {
    var
        d1 = [
            [0, friends_age[0]]
        ],
        d2 = [
            [0, friends_age[1]]
        ],
        d3 = [
            [0, friends_age[2]]
        ],
        d4 = [
            [0, friends_age[3]]
        ],
        d5 = [
            [0, friends_age[4]]
        ],
        d6 = [
            [0, friends_age[5]]
        ],
        graph;

    graph = Flotr.draw(container, [
        { data: d1, label: '10代' },
        { data: d2, label: '20代' },
        { data: d3, label: '30代' },
        { data: d4, label: '40代' },
        { data: d5, label: '50代' },
        { data: d6, label: 'その他' }
    ],
        {
            grid: {
                outlineWidth: 0,
                verticalLines: false,
                horizontalLines: false
            },
            xaxis: { showLabels: false },
            yaxis: { showLabels: false },
            pie: {
                show: true,
                explode: 6
            },
            mouse: { track: true },
            legend: {
                position: 'ne',
                backgroundColor: '#D2E8FF'
            }
        }
    );
};

// アクティビティ利用割合積み上げ棒グラフ
function activity_user_rate_bars_stacked(container, count) {
    var
        text_count = count['text_count'],
        link_count = count['link_count'],
        comment_count = count['comment_count'],
        photo_count = count['photo_count'],
        video_count = count['video_count'],
        checkin_count = count['checkin_count'],
        like_count = count['like_count'],
        total_count = text_count + link_count + comment_count + photo_count + video_count + checkin_count + like_count;

    var
        d1 = [],
        d2 = [],
        d3 = [],
        d4 = [],
        d5 = [],
        d6 = [],
        d7 = [],
        graph;

    d1.push([text_count, 0]);
    d2.push([comment_count, 0]);
    d3.push([photo_count, 0]);
    d4.push([video_count, 0]);
    d5.push([checkin_count, 0]);
    d6.push([like_count, 0]);
    d7.push([link_count, 0])

    graph = Flotr.draw(container, [
        { data: d1, label: 'テキスト' },
        { data: d2, label: 'コメント' },
        { data: d3, label: '写真' },
        { data: d4, label: '動画' },
        { data: d5, label: '場所' },
        { data: d6, label: 'いいね！' },
        { data: d7, label: 'リンク' }
    ], {
        legend: {
            backgroundColor: '#D2E8FF', // Light blue
            position: 'nw',
            noColumns: 4
        },
        bars: {
            show: true,
            stacked: true,
            horizontal: true,
            barWidth: 0.6,
            lineWidth: 1,
            shadowSize: 0
        },
        grid: {
            outlineWidth: 0,
            verticalLines: false,
            horizontalLines: false
        },
        yaxis: {
            showLabels: false
        },
        xaxis: {
            min: 0,
            max: total_count,
            showLabels: false

        }
    });
};

// いいね/コメント top3
function like_comment_top3_bars(container, likes_comments, names) {
    function markerFomatter(obj) {
        var name = names;
        return name[obj.y];
    }

    var min_count = likes_comments[2];
    var max_count = likes_comments[0];
    var yrange_max = max_count + (max_count) * 0.4;

    var point,
        d1 = [],
        markers = {data: [], markers: {show: true, position: 'rm', labelFormatter: markerFomatter, fontSize: 12}, bars: {show: false}};

    var p1 = [likes_comments[0], 2]
    d1.push(p1);
    markers.data.push(p1);
    var p2 = [likes_comments[1], 1]
    d1.push(p2);
    markers.data.push(p2);
    var p3 = [likes_comments[2], 0]
    d1.push(p3);
    markers.data.push(p3)


    /**
     * Draw the graph in the first container.
     */
    Flotr.draw(
        container,
        [d1, markers],
        {
            grid: {
                outlineWidth: 0,
                verticalLines: false,
                horizontalLines: false
            },
            bars: {show: true, barWidth: 0.5, horizontal: true},
            mouse: {track: true, relative: true},
            yaxis: {min: 0, autoscaleMargin: 1, showLabels: false},
            xaxis: {min: 0, max: yrange_max, showLabels: false}
        }
    );
}

function basic_line(container, post_growth) {

    var
        d2 = [], // First data series
        i, graph;

    for (i = 0; i < post_growth.length; i++) {
        d2.push([i, post_growth[i]]);
    }

    // Draw Graph
    graph = Flotr.draw(container, [ d2 ], {
        xaxis: {
            tickFormatter: function (x) {
                var month_array = []
                var start_month = (new Date()).getMonth() + 2;
                var month_str = '';
                for (i = 0; i < 12; i++) {
                    month_str = (start_month + i) % 12
                    if (month_str == 0) {
                        month_str = 12;
                    }
                    month_array.push(month_str + '月');
                }
                var
                    x = parseInt(x),
                    months = month_array;
                return months[x];
            }
        },
        grid: {
            minorVerticalLines: true
        }
    });
}

// test_flotr2用、2つ折れ線グラフ
function test_flotr2_basic_2line(container, post_growth1, post_growth2) {

    var
        d1 = [], // First data series
        d2 = [],
        x = [],
        i, graph;

    for (i = 0; i < post_growth1.length; i++) {
        d1.push([i, post_growth1[i]]);
    }

    for (i = 0; i < post_growth2.length; i++) {
        d2.push([i, post_growth2[i]]);
    }

    // Draw Graph
    graph = Flotr.draw(container, [ {data: d1,label: 'friend_count',lines: {show: true}, points:{show:true}},{data: d2,label: 'follower_count',lines: {show: true}, points:{show:true}}  ], {
        xaxis: {
//            ticks: x
        },
        yaxis: {
//            scaling: 'logarithmic',
//            base: 10
//            max: 100000
        },
        grid: {
            minorVerticalLines: true
        }
    });
}

// test_flotr2用、1つ折れ線グラフ
function test_flotr2_basic_1line(container, post_growth1) {

    var
        d1 = [], // First data series
        d2 = [],
        x = [],
        i, graph;

    for (i = 0; i < post_growth1.length; i++) {
        d1.push([i, post_growth1[i]]);
    }

    // Draw Graph
    graph = Flotr.draw(container, [ {data: d1,lines: {show: true}, points:{show:true}}  ], {
        xaxis: {
        },
        yaxis: {
        },
        grid: {
            minorVerticalLines: true
        }
    });
}