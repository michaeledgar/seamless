require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Seamless" do
  def load_example(name)
    require File.expand_path(File.dirname(__FILE__) + "/examples/#{name}")
  end
  
  it 'loads a simple method in endless form' do
    load_example 'simple'
    testing_method(50).should == '50, 50'
  end
  
  it 'loads a class in endless form' do
    load_example 'class'
    HelloThing.new('mike').run_ten_times.should == ['Hello, mike'] * 10
  end
  
  it 'loads endlessly formed rescues' do
    load_example 'rescue'
    Rescueable::Rescued.a_method.should == 5
  end
  
  it 'loads endless files with no newline at the end' do
    load_example 'no_newline_at_end'
    HelloWorlder.new.times_two.should == "Hello, world! Hello, world!"
  end
end
