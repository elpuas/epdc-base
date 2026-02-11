<?php
/**
 * EPDC Base Theme functions and definitions
 *
 * @package EPDC_Base
 */

// Prevent direct access
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Theme setup
 */
function epdc_base_setup() {
	// Add theme support for various WordPress features
	add_theme_support( 'wp-block-styles' );
	add_theme_support( 'align-wide' );
	add_theme_support( 'editor-styles' );
	add_theme_support( 'responsive-embeds' );

	// Add editor styles
	add_editor_style( 'build/editor-style.css' );
}
add_action( 'after_setup_theme', 'epdc_base_setup' );

/**
 * Enqueue scripts and styles
 */
function epdc_base_enqueue_assets() {
	$theme_version = wp_get_theme()->get( 'Version' );
	$build_path = get_template_directory() . '/build/';
	$build_url = get_template_directory_uri() . '/build/';

	// Enqueue main stylesheet if it exists
	if ( file_exists( $build_path . 'style-index.css' ) ) {
		$style_dependencies = [];

		// Check for asset file with dependencies
		if ( file_exists( $build_path . 'style-index.asset.php' ) ) {
			$style_assets = include $build_path . 'style-index.asset.php';
			$style_dependencies = $style_assets['dependencies'] ?? [];
			$theme_version = $style_assets['version'] ?? $theme_version;
		}

		wp_enqueue_style(
			'epdc-base-style',
			$build_url . 'style-index.css',
			$style_dependencies,
			$theme_version
		);
	}

	// Enqueue main script if it exists
	if ( file_exists( $build_path . 'index.js' ) ) {
		$script_dependencies = [];

		// Check for asset file with dependencies
		if ( file_exists( $build_path . 'index.asset.php' ) ) {
			$script_assets = include $build_path . 'index.asset.php';
			$script_dependencies = $script_assets['dependencies'] ?? [];
			$theme_version = $script_assets['version'] ?? $theme_version;
		}

		wp_enqueue_script(
			'epdc-base-script',
			$build_url . 'index.js',
			$script_dependencies,
			$theme_version,
			true
		);
	}
}
add_action( 'wp_enqueue_scripts', 'epdc_base_enqueue_assets' );
