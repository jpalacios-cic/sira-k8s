/* Zenmine Theme version 5.0, Copyright (C) 2019-2022 - Luis Blasco www.bestredminetheme.com */

/* INIT DARK MODE */

var my_stylesheet_url = $('head').find('link:first').attr('href');
let arr = my_stylesheet_url.split("/");

arr.pop();
arr.pop();

var themeroot = arr.join('/');

function dark(){

	if(localStorage.getItem('mode')=="dark"){	

		var html = '<link id="darkmode" rel="stylesheet" type="text/css" href="'+themeroot+'/stylesheets/dark.css" />';
		document.head.innerHTML += html;
		
	} else {
		
		if(document.getElementById('darkmode')){
			document.getElementById('darkmode').remove();
		}

	}

}

dark();

/* END DARK MODE */


function createBtn() {
	$("input[type=submit]").addClass("btn btn-sm btn-primary");
	$(".tab-content p a.icon").addClass("btn btn-sm btn-primary");
	$("#login-submit").addClass("btn btn-sm btn-primary");
	$("input[type=submit] + a.icon").addClass("btn btn-sm btn-outline-dark");
	$(".controller-enumerations.action-index #content p > a.icon").addClass("btn btn-sm btn-primary");

	$("#content").children(".contextual").find("a:first").addClass("btn btn-sm btn-primary");
	$("#content").children(".contextual").find("a:not(:first):not(.lock)").addClass("btn btn-sm btn-outline-dark");
	
	$(".issue .description .contextual a").addClass("btn btn-sm btn-outline-dark");
	$(".issue #relations .contextual a, .issue #issue_tree .contextual a").addClass("btn btn-sm btn-outline-dark");

	$("#content .contextual a.lock").addClass("btn btn-sm btn-danger");
	$(".news.box a:last").addClass("btn btn-sm btn-outline-dark");
	$("p.buttons a").addClass("btn btn-sm btn-outline-dark");
	$(".icon-fav-off").addClass("btn btn-sm btn-outline-dark");
	$("#activity_scope_form").find("p input").addClass("btn btn-sm btn-dark");
	$("table.query-columns .buttons input[type=button]").addClass("btn btn-sm btn-outline-dark");
}

function createDOMObserver(targetNode, callback) {
	if (targetNode) {
		const config = { attributes: true, childList: true, subtree: true };
		const observer = new MutationObserver(callback);
		observer.observe(targetNode, config);	
	}
}

function init() {
	$("table").wrap("<div class='table'></div>");
	createBtn();
}



$(document).ready(function() {

	/* INIT DARK MODE SWITCH */	

	if ($('body').hasClass('action-account')){		
  		$('<fieldset class="box"><legend>Dark Mode</legend><label><div class="switch-button" id="darkbutton"><input type="checkbox" name="switch-button" id="switch-label" class="switch-button__checkbox"><label for="switch-label" class="switch-button__label"></label></div></fieldset>').insertAfter('.splitcontentleft .box:first-child');		 		
  	}

  	if(localStorage.getItem('mode')=="dark"){
		$( ".switch-button__checkbox" ).prop( "checked", true );
	} else {
		
	}


  	$('#darkbutton').click(function(e){

  		e.preventDefault();

		if(localStorage.getItem('mode')=="dark"){			
			localStorage.setItem('mode', "light");
			$( ".switch-button__checkbox" ).prop( "checked", false);
		} else {
			localStorage.setItem('mode', "dark");
			$( ".switch-button__checkbox" ).prop( "checked", true);
		}
		dark();
		
	})

	/* END DARK MODE SWITCH */


	if ($('body').hasClass('action-login')){
		$('#login-form > form').prepend("<div class='logo_login'></div>");
	}

	if ($('body').hasClass('action-register')){
		
		$(window).resize(function(){
			if($('body').hasClass('action-register')){
				$('#content').css("height",$(document).height());
			} 
		});
	
		$('#content').css("height",$(document).height());

		$('#new_user').prepend("<div class='logo_login'></div>");
	}

	if ($('body').hasClass('action-lost_password')){
		$('.box.tabular').prepend("<div class='logo_login'></div>");	
	}

	$('.toggle-multiselect').click(function(){
		$(this).parent().parent().prev().addClass('multiselectarrow');
	})

		
	if ($('body').hasClass('action-login') || $('body').hasClass('action-register') || $('body').hasClass('action-lost_password')) {
		$('<div id="hero"></div>').prependTo('#content')
	} else {
		if(!$('#main').hasClass('nosidebar')){
			$('<span class="openclose"></span>').prependTo('#content');
		}
	}
	
	if($("#sidebar").css("float")=="right"){
		$('#main').addClass("flip");
	}
	
	if(localStorage.getItem('sidebar')=="closed"){		
		$('#content').toggleClass('full-width');
		$('#sidebar').toggleClass('sidebar-hide');
		/*$('#content').css('width', '99%');
		$('#content').css('transition', '0');
		$('#sidebar').css('margin-left', '-14%');
		$('#sidebar').css('transition', '0');*/
	}
	
	//if($('#header').height()>120 && ($(document).height() - $(window).height()) > 200){
		
		var stickyNavTop = $('#header').offset().top;
	 
		var stickyNav = function(){
			
			var scrollTop = $(window).scrollTop();			
				  
			if (scrollTop > stickyNavTop) { 
				$('body:not(.admin):not(.action-login):not(.action-register):not(.action-lost_password) #header').addClass('sticky');
			} else {
				$('body:not(.admin) #header').removeClass('sticky'); 
			}			
			
		}; 

			
		function offsetAnchor() {
			if(location.hash.length !== 0) {
				window.scrollTo(window.scrollX, window.scrollY - $('#header').outerHeight());
			}
		}


		window.addEventListener("hashchange", offsetAnchor);
		
		offsetAnchor();
		
		//var style = getComputedStyle(document.body);		

		//if(style.getPropertyValue('--sticky')){

			stickyNav();
			
			$(window).scroll(function() {
			  stickyNav();
			});
			
		//}
	//}
	

	$('.openclose').click(function(){

		$('#content').toggleClass('full-width');
		$('#sidebar').toggleClass('sidebar-hide');
		$('#content').addClass("transition");
		$('#sidebar').addClass("transition");

		if(localStorage.getItem('sidebar')=="closed"){		
			localStorage.setItem('sidebar', "open");
		} else{
			localStorage.setItem('sidebar', "closed");
		}

	})

	$('.action-login .lost_password, .action-register .lost_password').insertAfter('#password')

	$('.action-register #new_user').wrap('<div id="login-form"></div>')

	init();


	$('td.priority').each(function() {
    	$(this).wrapInner( "<div class='priority_"+$(this).html()+"'></div>");
    })

    $('.priority.attribute .value').each(function() {
    	$(this).wrapInner( "<div class='priority_"+$(this).html()+"'></div>");
    })


	if(!$('#filters').hasClass("collapsed")){
		$('#filters legend').trigger( "click" );
	}


	function collapsible() {
		if( $('.collapsible').parent().find('.collapsed').length >= 2 || ($('.collapsible').parent().find('fieldset').length == $('.collapsible').parent().find('.collapsed').length)){
			$('#query_form_with_buttons .buttons').css("display", "none");
			$('#query_form p.buttons').css("display", "none");
			$('#query_form #filters div').css("display", "none");
		} else {
			$('#query_form_with_buttons .buttons').css("display", "inline-block");
			$('#query_form p.buttons').css("display", "inline-block");
			$('#query_form #filters div').css("display", "inline-block");
		}

	}

	collapsible();

	$('#query_form_content').click(collapsible);
	$('.filters #query_form').click(collapsible);
	$('#query_form legend').click(collapsible);


	$('#filters legend').click(function(){
		$('#filters-table .filter .field input').click(function(){ 
			$(this).parent().parent().find('.operator').toggleClass('afterhidding')
		})
	})
	

	
	/*$('.projects.root .root ul.projects').click(function(e) {
	    if (e.clientX > $(this).offset().left - 21 &&
			e.clientY < $(this).offset().top + 50) {
			$('.projects.root .root ul.projects li .projects').slideToggle('fast')
	    
	});}*/
	
	var number=1;

	
	$("#projects-index ul.projects > li > .root, #projects-index > ul.projects  > li  > ul.projects > li > .child, #projects-index > ul.projects  > li  > ul.projects > li > ul.projects > li > .child").each(function() {	
	
		if($(this).next(".projects").length){
			
			$(this).prepend( "<div id='project_"+number+"' class='projectshide open'></div>" );
		
			if(localStorage.getItem("project_"+number)=="closed"){		
				$('#project_'+number).parent().parent().children('ul.projects').css("display", "none");
				$('#project_'+number).removeClass("open");
				$('#project_'+number).addClass("closed");
			}
			
			number++;
		}
		
	});
	
	$('.projectshide').click(function(){
	
		var projectid = $(this).attr('id');	
		
		if(localStorage.getItem(projectid)!="closed"){
			
			localStorage.setItem(projectid, "closed");
			$('#'+projectid).removeClass("open");
			$('#'+projectid).addClass("closed");
			$('#'+projectid).parent().parent().children('ul.projects').css("display", "none");		
			
		} else {
			
			localStorage.setItem(projectid, "open");
			$('#'+projectid).removeClass("closed");
			$('#'+projectid).addClass("open");
			$('#'+projectid).parent().parent().children('ul.projects').css("display", "block");
					
		}
	});
	

	$('#add_filter_select').click(function(){ 

		$('.values .toggle-multiselect').click(function(){
			$(this).parent().parent().parent().toggleClass('filteropen')
		})

		$('#filters-table .filter .field input').click(function(){ 
			$(this).parent().parent().find('.operator').toggleClass('afterhidding')
		})

	});


	$('<span class="rightarrow"></span>').insertAfter($('input[value="→"]'))
	$('<span class="leftarrow"></span>').insertAfter($('input[value="←"]'))

	$('<span class="totop"></span>').insertAfter($('input[value="⇈"]'))
	$('<span class="goup"></span>').insertAfter($('input[value="↑"]'))
	$('<span class="godown"></span>').insertAfter($('input[value="↓"]'))
	$('<span class="tobottom"></span>').insertAfter($('input[value="⇊"]'))


});

$(window).on('load', function() {

	/*Start Parche sprint */

	$("#values_sprint_id_1").on('change', function (){
         alert($('#values_sprint_id_1 option:selected').text());
  	});

	/*End Parche sprint */
	
});