$(function(){
    $(".no-problem").click(function(){
        var form = $(this).parent().prev('.tweet-form').children('form');
        form.children("[name='check[answer]']").val(false);
        form.submit();
    });

    $(".may-burn").click(function(){
        var form = $(this).parent().prevAll('.tweet-form').children('form');
        form.children("[name='check[answer]']").val(true);
        form.submit();
    });
});