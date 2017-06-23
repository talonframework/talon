$('body').on('click', '.delete-link', function(e) {
  e.preventDefault()
  e.stopPropagation()
  var url = $(this).attr('href');
  console.log('url', url)
  swal({
    title: "Are you sure?",
    text: "The record will be permanently deleted!",
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: "Yes, delete it!",
    closeOnConfirm: false,
  }, function(){
    $('#delete-form form').attr('action', url).submit()
  });
})
