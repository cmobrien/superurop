class Problem < ActiveRecord::Base
	require "open3"

	def self.concepts
		JSON.parse(File.open('concepts/concepts.json').read)['concepts']
	end

	def self.update_concepts
		dot = "digraph test {\n"
		c = JSON.parse(File.open('concepts/concepts.json').read)['concepts']
		for topic in c
			for prereq in topic['prerequisites']
				dot = dot + "\"" + topic['name'] + "\" -> \"" + prereq + "\"\n"
			end
			for assumed in topic['assumed']
				dot = dot + "\"" + topic['name'] + "\" -> \"" + assumed + "\" [style = dotted] \n"
			end
		end
		dot = dot + "}"
		
		File.open('test.dot', 'w') { |file|
			file.write(dot) }

		Open3.popen3("dot -T png test.dot -o outfile.png")
	end


	def self.get_names
		master_url = "https://api.github.com/repos/cmobrien/superurop/git/trees/master"
		master = JSON.parse(open(master_url).read())

		trees = master['tree']
		for tree in trees
			if tree['path'] == 'problems'
				sha = tree['sha']
			end
		end

		problems_url = "https://api.github.com/repos/cmobrien/superurop/git/trees/" + sha.to_s
		problems = JSON.parse(open(problems_url).read())

		names = []
		for problem in problems['tree']
			if problem['type'] == 'tree' && check_problem(problem)
				names.push(problem['path'])
			end
		end
		return names
	end

	def self.check_problem(problem)
		problem_url = "https://api.github.com/repos/cmobrien/superurop/git/trees/" + problem['sha'].to_s
		problem_folder = JSON.parse(open(problem_url).read())

		needed = ['python.py', 'template.java', 'tests.java', 'problem.txt', 'solution.java']
		for item in problem_folder['tree']
			if needed.include?(item['path'])
				needed.delete(item['path'])
			end
		end
		return needed.length == 0
	end

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

	def update
		changed = false
		
		python_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + self.name + "/python.py"
		python = open(python_url).read()

		template_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + self.name + "/template.java"
		template = open(template_url).read()

		tests_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + self.name + "/tests.java"
		tests = open(tests_url).read()

		problem_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + self.name + "/problem.txt"
		problem = open(problem_url).read()

		solution_url = "https://raw.github.com/cmobrien/superurop/master/problems/" + self.name + "/solution.java"
		solution = open(solution_url).read()

		if (python != self.python) || (template != self.template) || (tests != self.tests) || (problem != self.problem) || (solution != self.solution)
			changed = true
		end

		self.python = python
		self.template = template
		self.tests = tests
		self.problem = problem
		self.solution = solution
		return changed
	end


	def valid_code?
		errors = []
		valid = false
		# Check if solution compiles
		if compile_solution

			# Check if tests compile
			if compile_tests

				# Check if solution passes tests
				if run_solution
					valid = true
				else
					errors.push('Solution did not pass test for ' + self.name)
				end

			else
				errors.push('Tests did not compile for ' + self.name)
			end

		else
			errors.push('Solution did not compile for ' + self.name)
		end
		return valid, errors
	end

	def compile_solution
		solution_text = self.solution.squish.gsub('"', '\\\\\\\\\\"')

		command = "java -cp java/bin Compile \"{\\\"" + self.name.capitalize + "Class\\\":\\\"" + solution_text + "\\\"}\""

		input, output, error = Open3.popen3(command)
		input.close
		output.close
		comp_error = error.read
		error.close

		comp_error.length <= 26
	end

	def compile_tests
		tests_text = self.tests.squish.gsub('"', '\\\\\\\\\\"')

		command = "java -cp java/bin:/usr/share/java/junit.jar Compile \"{\\\"" + self.name.capitalize + "Test\\\":\\\"" + tests_text + "\\\"}\""

		input, output, error = Open3.popen3(command)
		input.close
		output.close
		comp_error = error.read
		error.close

		comp_error.length <= 26
	end

	def run_solution
		command = "java -cp java/bin:/usr/share/java/junit.jar org.junit.runner.JUnitCore " + self.name.capitalize + "Test"

		input, output, error = Open3.popen3(command)

		input.close
		out = output.read
		output.close
		run_error = error.read
		error.close

		run_error.length <= 26 && out.length < 60
	end
end
