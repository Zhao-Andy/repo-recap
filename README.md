# Repo Recap

The Repo Recap Writer is a simple command line tool to help you write an automated summary of the latest pull requests and issues in your repository. It generates Markdown to be copy and pasted, and you can use that Markdown to publish a new post on dev.to.

## Warning: 🚧 This is currently still a work in progress! 🚧

There's a lot of general purposing work to be done. This originally started as a bit of a side project, and most of it is built with hard-coded solutions. Since this was made by me ([Andy Zhao](https://dev.to/andy)) to automate my own workflow, you can also consider me the maintainer of this project.

## Usage

This tool is essentially a command line tool/script, meant to be run locally. To get up and running:

1. Clone the repository.
2. Create two files in the folder:
  - `environment.rb`: This is where you store your environment variables. You can copy over the sample from: `environment_sample.rb`
  - `special_usernames.rb`: This is for any GitHub usernames that are not the same on dev.to. This allows you to link properly to people's dev.to profiles. You can copy over the sample from: `special_usernames_sample.rb`
3. Fill out the environment variables in `environment.rb` and add any usernames to `special_usernames.rb`.
4. Run the repo recap:
```bash
ruby repo_recap_writer.rb
```
5. Once the process is complete, you should see an output that you can copy and paste into https://dev.to/new. There's a current limitation in that you must be using the v1 editor.

## Contributing

It's a pretty small project, so contributing should be pretty straightforward. Feel free to make a pull request to help out with making this more general purpose or create issues if you have any questions or comments.

A simple outline/roadmap will be up soon.

Thanks for checking this project out!
