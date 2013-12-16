class Problem < ActiveRecord::Base
	require "open3"

	def self.build(name)
		python_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + name + "/python.py"
		python = open(python_url).read()

		template_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + name + "/template.java"
		template = open(template_url).read()

		tests_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + name + "/tests.java"
		tests = open(tests_url).read()

		problem_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + name + "/problem.txt"
		problem = open(problem_url).read()

		solution_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + name + "/solution.java"
		solution = open(solution_url).read()


		Problem.new(name: name,
					python: python,
					template: template,
					tests: tests,
					problem: problem,
					solution: solution)
	end

	def valid?
		# Check if solution compiles
		compile_solution
		compile_tests
		run_solution

		# Check if tests compile

		# Check if solution passes tests
	end

	def compile_solution
		solution_text = self.solution.squish.gsub('"', '\\\\\\\\\\"')

		command = "java -cp java/bin Compile \"{\\\"" + self.name.capitalize + "Class\\\":\\\"" + solution_text + "\\\"}\""
		puts '----------------------------------'
		puts command
		puts '----------------------------------'

		input, output, error = Open3.popen3(command)
		input.close
		output.close
		comp_error = error.read
		error.close

		puts '----------------------------------'
		puts comp_error
		puts '----------------------------------'

		comp_error.length > 26
	end

	def compile_tests
		tests_text = self.tests.squish.gsub('"', '\\\\\\\\\\"')

		command = "java -cp java/bin:/usr/share/java/junit.jar Compile \"{\\\"" + self.name.capitalize + "Test\\\":\\\"" + tests_text + "\\\"}\""
		puts '----------------------------------'
		puts command
		puts '----------------------------------'

		input, output, error = Open3.popen3(command)
		input.close
		output.close
		comp_error = error.read
		error.close

		puts '----------------------------------'
		puts comp_error
		puts '----------------------------------'

		comp_error.length > 26
	end

	def run_solution
		command = "java -cp java/bin:/usr/share/java/junit.jar org.junit.runner.JUnitCore " + self.name.capitalize + "Test.java"
		puts '----------------------------------'
		puts command
		puts '----------------------------------'

		input, output, error = Open3.popen3(command)

		input.close
		out = output.read
		output.close
		run_error = error.read
		error.close

		puts '----------------------------------'
		puts run_error
		puts out
		puts '----------------------------------'

		run_error.length > 26
	end
end
