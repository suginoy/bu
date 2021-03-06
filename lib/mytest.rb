require 'mechanize'

def setup(uribase)
  @agent = Mechanize.new
  @uribase = uribase
  @successes = 0
  @failures = 0
  @context_depth = 0
  i_puts "setup: #{uribase}"
  indent { yield if block_given? }
end

def context(name)
  i_puts "context: #{name}"
  indent { yield if block_given? }
end

def indent
  @context_depth += 1
  yield if block_given?
  @context_depth -= 1
end

def i_puts(*args)
  args.each {|e| puts '  ' * @context_depth + e.to_s }
end

def get(path)
  @agent.get(@uribase + path)
  shuld_not_have_content('Error')
end

def click(*args)
  page.link_with(*args).click
  shuld_not_have_content('Error')
end

def page
  @agent.page
end

def body
  page.body
end

def page_form_with(form_id, modelname, fields = {})
  page.form_with(:id => form_id.to_s) {|form|
    fields.each do |field, value|
      form.field_with(:id => "#{modelname}_#{field}").value = value
    end
  }
end

def have_content?(str, tag)
  page.at(tag).inner_text.toutf8.include?(str.toutf8)
end

def shuld_have_content(str, tag = :html)
  have_content?(str, tag) ? success : failure
end

def shuld_not_have_content(str, tag = :html)
  have_content?(str, tag) ? failure : success
end

def shuld_be_path(ptn)
  ptn === page.uri.path ? success : failure
end

def assert(cond, msg = nil)
  cond ? success : failure
end

def success
  i_puts 'pass'
  @successes += 1
end

def failure(depth = 1) # todo: delete depth. search another script name.
  i_puts "failure: #{caller[depth]}"
  @failures += 1
end

def uniq_string(len)
  rand(36 ** len).to_s(36)
end

END {
  puts "successes: #{@successes}"
  puts "failures: #{@failures}"
}
