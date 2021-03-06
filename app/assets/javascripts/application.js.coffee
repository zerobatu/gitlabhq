# This is a manifest file that'll be compiled into including all the files listed below.
# Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
# be included in the compiled file accessible from http://example.com/assets/application.js
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
#= require jquery
#= require jquery.ui.all
#= require jquery_ujs
#= require jquery.cookie
#= require jquery.endless-scroll
#= require jquery.highlight
#= require jquery.history
#= require jquery.waitforimages
#= require jquery.atwho
#= require jquery.scrollTo
#= require jquery.blockUI
#= require jquery.turbolinks
#= require jquery.sticky-kit.min
#= require turbolinks
#= require autosave
#= require bootstrap
#= require select2
#= require raphael
#= require g.raphael-min
#= require g.bar-min
#= require chart-lib.min
#= require branch-graph
#= require ace/ace
#= require ace/ext-searchbox
#= require d3
#= require underscore
#= require nprogress
#= require nprogress-turbolinks
#= require dropzone
#= require mousetrap
#= require mousetrap/pause
#= require shortcuts
#= require shortcuts_navigation
#= require shortcuts_dashboard_navigation
#= require shortcuts_issuable
#= require shortcuts_network
#= require cal-heatmap
#= require_tree .

window.slugify = (text) ->
  text.replace(/[^-a-zA-Z0-9]+/g, '_').toLowerCase()

window.ajaxGet = (url) ->
  $.ajax({type: "GET", url: url, dataType: "script"})

window.showAndHide = (selector) ->

window.split = (val) ->
  return val.split( /,\s*/ )

window.extractLast = (term) ->
  return split( term ).pop()

window.rstrip = (val) ->
  return if val then val.replace(/\s+$/, '') else val

# Disable button if text field is empty
window.disableButtonIfEmptyField = (field_selector, button_selector) ->
  field = $(field_selector)
  closest_submit = field.closest('form').find(button_selector)

  closest_submit.disable() if rstrip(field.val()) is ""

  field.on 'input', ->
    if rstrip($(@).val()) is ""
      closest_submit.disable()
    else
      closest_submit.enable()

# Disable button if any input field with given selector is empty
window.disableButtonIfAnyEmptyField = (form, form_selector, button_selector) ->
  closest_submit = form.find(button_selector)
  updateButtons = ->
    filled = true
    form.find('input').filter(form_selector).each ->
      filled = rstrip($(this).val()) != "" || !$(this).attr('required')

    if filled
      closest_submit.enable()
    else
      closest_submit.disable()

  updateButtons()
  form.keyup(updateButtons)

window.sanitize = (str) ->
  return str.replace(/<(?:.|\n)*?>/gm, '')

window.linkify = (str) ->
  exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
  return str.replace(exp,"<a href='$1'>$1</a>")

window.simpleFormat = (str) ->
  linkify(sanitize(str).replace(/\n/g, '<br />'))

window.unbindEvents = ->
  $(document).unbind('scroll')
  $(document).off('scroll')

window.shiftWindow = ->
  scrollBy 0, -50

document.addEventListener("page:fetch", unbindEvents)

# Scroll the window to avoid the topnav bar
# https://github.com/twitter/bootstrap/issues/1768
if location.hash
  setTimeout shiftWindow, 1
window.addEventListener "hashchange", shiftWindow

$ ->
  # Click a .js-select-on-focus field, select the contents
  $(".js-select-on-focus").on "focusin", ->
    # Prevent a mouseup event from deselecting the input
    $(this).select().one 'mouseup', (e) ->
      e.preventDefault()

  $('.remove-row').bind 'ajax:success', ->
    $(this).closest('li').fadeOut()

  # Initialize select2 selects
  $('select.select2').select2(width: 'resolve', dropdownAutoWidth: true)

  # Close select2 on escape
  $('.js-select2').bind 'select2-close', ->
    setTimeout ( ->
      $('.select2-container-active').removeClass('select2-container-active')
      $(':focus').blur()
    ), 1

  # Initialize tooltips
  $('body').tooltip({
    selector: '.has_tooltip, [data-toggle="tooltip"], .page-sidebar-collapsed .nav-sidebar a'
    placement: (_, el) ->
      $el = $(el)
      if $el.attr('id') == 'js-shortcuts-home'
        # Place the logo tooltip on the right when collapsed, bottom when expanded
        $el.parents('header').hasClass('header-collapsed') and 'right' or 'bottom'
      else
        # Otherwise use the data-placement attribute, or 'bottom' if undefined
        $el.data('placement') or 'bottom'
  })

  # Form submitter
  $('.trigger-submit').on 'change', ->
    $(@).parents('form').submit()

  $("abbr.timeago").timeago()
  $('.js-timeago').timeago()

  # Flash
  if (flash = $(".flash-container")).length > 0
    flash.click -> $(@).fadeOut()
    flash.show()

  # Disable form buttons while a form is submitting
  $('body').on 'ajax:complete, ajax:beforeSend, submit', 'form', (e) ->
    buttons = $('[type="submit"]', @)

    switch e.type
      when 'ajax:beforeSend', 'submit'
        buttons.disable()
      else
        buttons.enable()

  # Show/Hide the profile menu when hovering the account box
  $('.account-box').hover -> $(@).toggleClass('hover')

  # Commit show suppressed diff
  $(".diff-content").on "click", ".supp_diff_link", ->
    $(@).next('table').show()
    $(@).remove()

  # Show/hide comments on diff
  $("body").on "click", ".js-toggle-diff-comments", (e) ->
    $(@).toggleClass('active')
    $(@).closest(".diff-file").find(".notes_holder").toggle()
    e.preventDefault()

  $(document).off "click", '.js-confirm-danger'
  $(document).on "click", '.js-confirm-danger', (e) ->
    e.preventDefault()
    btn = $(e.target)
    text = btn.data("confirm-danger-message")
    form = btn.closest("form")
    new ConfirmDangerModal(form, text)

  new Aside()

(($) ->
  # Disable an element and add the 'disabled' Bootstrap class
  $.fn.extend disable: ->
    $(@).attr('disabled', 'disabled').addClass('disabled')

  # Enable an element and remove the 'disabled' Bootstrap class
  $.fn.extend enable: ->
    $(@).removeAttr('disabled').removeClass('disabled')

)(jQuery)
